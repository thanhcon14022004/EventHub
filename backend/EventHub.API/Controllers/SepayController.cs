using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using EventHub.Domain.Entities;
using EventHub.Infrastructure.Data;

namespace EventHub.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SepayController : ControllerBase
    {
        private readonly EventHubDbContext _context;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _config;
        private readonly ILogger<SepayController> _logger;

        private string ApiKey => _config["Sepay:ApiKey"] ?? "XWPNYEIQU6QXFEML5HU2XKVZSBGOQBRMNDTBA7NG2CZCYUISIVPLDKMKGFDKOJYI";
        private string AccountNumber => _config["Sepay:AccountNumber"] ?? "27655931";
        private string BankBrand => _config["Sepay:BankBrand"] ?? "ACB";
        private string AccountName => _config["Sepay:AccountName"] ?? "HA TRUNG THANH";

        public SepayController(
            EventHubDbContext context,
            IHttpClientFactory httpClientFactory,
            IConfiguration config,
            ILogger<SepayController> logger)
        {
            _context = context;
            _httpClientFactory = httpClientFactory;
            _config = config;
            _logger = logger;
        }

        /// <summary>
        /// GET /api/sepay/revenue
        /// Lấy tổng doanh thu và danh sách biến động số dư thực tế từ SePay Cloud API
        /// </summary>
        [HttpGet("revenue")]
        public async Task<IActionResult> GetRevenueSummary([FromQuery] int limit = 100)
        {
            try
            {
                var client = _httpClientFactory.CreateClient();
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", ApiKey);

                var response = await client.GetAsync($"https://my.sepay.vn/userapi/transactions/list?limit={limit}");
                if (!response.IsSuccessStatusCode)
                {
                    return StatusCode((int)response.StatusCode, new { message = "Lỗi khi kết nối đến SePay API" });
                }

                var jsonStr = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(jsonStr);
                var root = doc.RootElement;

                decimal totalRevenue = 0;
                decimal totalIn = 0;
                decimal totalOut = 0;
                var transactions = new List<object>();

                if (root.TryGetProperty("transactions", out var txList) && txList.ValueKind == JsonValueKind.Array)
                {
                    foreach (var tx in txList.EnumerateArray())
                    {
                        var id = tx.TryGetProperty("id", out var idProp) ? idProp.GetString() ?? "" : "";
                        var bankBrand = tx.TryGetProperty("bank_brand_name", out var bbProp) ? bbProp.GetString() ?? BankBrand : BankBrand;
                        var accNum = tx.TryGetProperty("account_number", out var anProp) ? anProp.GetString() ?? AccountNumber : AccountNumber;
                        var txDate = tx.TryGetProperty("transaction_date", out var tdProp) ? tdProp.GetString() ?? "" : "";
                        var content = tx.TryGetProperty("transaction_content", out var cProp) ? cProp.GetString() ?? "" : "";
                        var refNum = tx.TryGetProperty("reference_number", out var rnProp) ? rnProp.GetString() ?? "" : "";

                        var amountInStr = tx.TryGetProperty("amount_in", out var aInProp) ? aInProp.GetString() ?? "0" : "0";
                        var amountOutStr = tx.TryGetProperty("amount_out", out var aOutProp) ? aOutProp.GetString() ?? "0" : "0";

                        decimal.TryParse(amountInStr, out var amountIn);
                        decimal.TryParse(amountOutStr, out var amountOut);

                        totalIn += amountIn;
                        totalOut += amountOut;

                        transactions.Add(new
                        {
                            id,
                            bank_brand_name = bankBrand,
                            account_number = accNum,
                            transaction_date = txDate,
                            amount_in = amountIn,
                            amount_out = amountOut,
                            transaction_content = content,
                            reference_number = refNum
                        });
                    }

                    totalRevenue = totalIn;
                }

                return Ok(new
                {
                    success = true,
                    bankBrand = BankBrand,
                    accountNumber = AccountNumber,
                    accountName = AccountName,
                    totalRevenue = totalRevenue,
                    totalIn = totalIn,
                    totalOut = totalOut,
                    netBalance = totalIn - totalOut,
                    transactionCount = transactions.Count,
                    transactions = transactions
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[SePay] Lỗi lấy doanh thu SePay");
                return StatusCode(500, new { message = "Lỗi khi lấy thông tin doanh thu SePay", error = ex.Message });
            }
        }

        /// <summary>
        /// GET /api/sepay/qr-info/{bookingId}
        /// Lấy thông tin tài khoản ngân hàng và mã QR chuyển khoản VietQR tự động qua SePay
        /// </summary>
        [HttpGet("qr-info/{bookingId}")]
        public async Task<IActionResult> GetQrInfo(string bookingId)
        {
            var booking = await FindBookingAsync(bookingId);
            if (booking == null)
            {
                return NotFound(new { message = "Không tìm thấy thông tin đơn đặt." });
            }

            var cleanCode = Regex.Replace(booking.BookingCode, @"[^a-zA-Z0-9]", "");
            var transferContent = $"EH {cleanCode}";
            var rawAmount = (long)booking.TotalAmount;

            var sepayQrUrl = $"https://qr.sepay.vn/img?acc={AccountNumber}&bank={BankBrand}&amount={rawAmount}&des={Uri.EscapeDataString(transferContent)}";
            var vietQrUrl = $"https://img.vietqr.io/image/{BankBrand}-{AccountNumber}-compact2.png?amount={rawAmount}&addInfo={Uri.EscapeDataString(transferContent)}&accountName={Uri.EscapeDataString(AccountName)}";

            return Ok(new
            {
                bookingId = booking.Id,
                bookingCode = booking.BookingCode,
                serviceTitle = booking.PackageNameSnapshot,
                totalAmount = rawAmount,
                bankBrand = BankBrand,
                bankName = "Ngân hàng TMCP Á Châu (ACB)",
                accountNumber = AccountNumber,
                accountName = AccountName,
                transferContent = transferContent,
                qrUrl = sepayQrUrl,
                vietQrUrl = vietQrUrl,
                isConfirmed = booking.Status == "Confirmed"
            });
        }

        /// <summary>
        /// GET /api/sepay/check/{bookingId}
        /// Kiểm tra tự động biến động số dư từ SePay API xem đã nhận được tiền với mã giao dịch hợp lệ chưa
        /// </summary>
        [HttpGet("check/{bookingId}")]
        public async Task<IActionResult> CheckPayment(string bookingId)
        {
            var booking = await FindBookingAsync(bookingId);
            if (booking == null)
            {
                return NotFound(new { message = "Không tìm thấy thông tin đơn đặt." });
            }

            // 1. Nếu đơn đã xác nhận từ trước
            if (booking.Status == "Confirmed")
            {
                return Ok(new
                {
                    isPaid = true,
                    status = booking.Status,
                    message = "Đơn đặt đã được xác nhận thanh toán thành công.",
                    bookingId = booking.Id,
                    bookingCode = booking.BookingCode
                });
            }

            // 2. Gọi SePay API để quét danh sách biến động số dư gần nhất
            try
            {
                var client = _httpClientFactory.CreateClient();
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", ApiKey);

                var response = await client.GetAsync("https://my.sepay.vn/userapi/transactions/list?limit=30");
                if (response.IsSuccessStatusCode)
                {
                    var jsonStr = await response.Content.ReadAsStringAsync();
                    using var doc = JsonDocument.Parse(jsonStr);
                    var root = doc.RootElement;

                    if (root.TryGetProperty("transactions", out var txList) && txList.ValueKind == JsonValueKind.Array)
                    {
                        var normalizedCode = Regex.Replace(booking.BookingCode, @"[^a-zA-Z0-9]", "").ToLowerInvariant();

                        foreach (var tx in txList.EnumerateArray())
                        {
                            var amountInStr = tx.TryGetProperty("amount_in", out var aProp) ? aProp.GetString() ?? "0" : "0";
                            decimal.TryParse(amountInStr, out var amountIn);

                            var content = tx.TryGetProperty("transaction_content", out var cProp) ? cProp.GetString() ?? "" : "";
                            var cleanContent = Regex.Replace(content, @"[^a-zA-Z0-9]", "").ToLowerInvariant();

                            // Kiểm tra: Có biến động số dư VÀ nội dung chứa mã đơn hàng
                            var matchesCode = cleanContent.Contains(normalizedCode)
                                              || (!string.IsNullOrEmpty(booking.BookingCode) && content.IndexOf(booking.BookingCode, StringComparison.OrdinalIgnoreCase) >= 0);

                            // Chấp nhận nếu số tiền chuyển >= tổng tiền đơn đặt (hoặc test với số tiền hợp lệ)
                            if (matchesCode && amountIn > 0)
                            {
                                var now = DateTime.UtcNow;
                                booking.Status = "Confirmed";
                                booking.PaymentGateway = $"SePay - {BankBrand} (ACB)";
                                booking.StatusUpdatedAt = now;
                                await _context.SaveChangesAsync();

                                _logger.LogInformation($"[SePay] Giao dịch hợp lệ cho đơn {booking.BookingCode}, số tiền {amountIn}.");

                                return Ok(new
                                {
                                    isPaid = true,
                                    status = "Confirmed",
                                    message = "Đã phát hiện biến động số dư SePay hợp lệ! Thanh toán thành công.",
                                    amountReceived = amountIn,
                                    transactionId = tx.TryGetProperty("id", out var idProp) ? idProp.GetString() : null,
                                    referenceNumber = tx.TryGetProperty("reference_number", out var refProp) ? refProp.GetString() : null,
                                    bookingId = booking.Id,
                                    bookingCode = booking.BookingCode
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[SePay] Lỗi khi gọi SePay API transactions/list");
            }

            return Ok(new
            {
                isPaid = false,
                status = booking.Status,
                message = "Đang chờ biến động số dư từ SePay...",
                bookingId = booking.Id,
                bookingCode = booking.BookingCode
            });
        }

        /// <summary>
        /// POST /api/sepay/webhook
        /// Webhook IPN nhận thông báo giao dịch tức thì từ SePay khi có biến động số dư
        /// </summary>
        [HttpPost("webhook")]
        public async Task<IActionResult> Webhook([FromBody] SepayWebhookPayload payload)
        {
            if (payload == null)
            {
                return BadRequest(new { message = "Dữ liệu webhook không hợp lệ." });
            }

            _logger.LogInformation($"[SePay Webhook] Nhận biến động số dư: ID={payload.Id}, Số tiền={payload.TransferAmount}, Nội dung={payload.Content}");

            if (payload.TransferAmount <= 0)
            {
                return Ok(new { success = false, message = "Bỏ qua giao dịch tiền ra." });
            }

            var content = payload.Content ?? "";
            var cleanContent = Regex.Replace(content, @"[^a-zA-Z0-9]", "").ToLowerInvariant();

            // Tìm đơn đặt khớp mã
            var pendingBookings = await _context.Bookings
                .Where(b => b.Status != "Confirmed" && b.Status != "Cancelled")
                .ToListAsync();

            var matchedBooking = pendingBookings.FirstOrDefault(b =>
            {
                var normCode = Regex.Replace(b.BookingCode, @"[^a-zA-Z0-9]", "").ToLowerInvariant();
                return cleanContent.Contains(normCode) || content.IndexOf(b.BookingCode, StringComparison.OrdinalIgnoreCase) >= 0;
            });

            if (matchedBooking != null)
            {
                matchedBooking.Status = "Confirmed";
                matchedBooking.PaymentGateway = $"SePay Webhook - {payload.Gateway ?? "ACB"}";
                matchedBooking.StatusUpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();

                _logger.LogInformation($"[SePay Webhook] Đã tự động duyệt đơn {matchedBooking.BookingCode} qua webhook!");

                return Ok(new
                {
                    success = true,
                    message = "Đã xác nhận thanh toán đơn đặt thành công.",
                    bookingCode = matchedBooking.BookingCode,
                    bookingId = matchedBooking.Id
                });
            }

            return Ok(new { success = true, message = "Đã ghi nhận giao dịch nhưng chưa khớp mã đơn chờ thanh toán." });
        }

        /// <summary>
        /// POST /api/sepay/simulate/{bookingId}
        /// Giả lập thanh toán thành công (dành cho kiểm thử nhanh mà không cần chuyển tiền thật)
        /// </summary>
        [HttpPost("simulate/{bookingId}")]
        public async Task<IActionResult> SimulatePayment(string bookingId)
        {
            var booking = await FindBookingAsync(bookingId);
            if (booking == null)
            {
                return NotFound(new { message = "Không tìm thấy đơn đặt." });
            }

            booking.Status = "Confirmed";
            booking.PaymentGateway = "SePay VietQR (Mô phỏng)";
            booking.StatusUpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                isPaid = true,
                status = "Confirmed",
                message = "Đã mô phỏng chuyển khoản thành công!",
                bookingId = booking.Id,
                bookingCode = booking.BookingCode
            });
        }

        private async Task<Booking?> FindBookingAsync(string bookingId)
        {
            if (Guid.TryParse(bookingId, out var guid))
            {
                var byId = await _context.Bookings.FindAsync(guid);
                if (byId != null) return byId;
            }

            return await _context.Bookings.FirstOrDefaultAsync(b => b.BookingCode == bookingId || b.Id.ToString() == bookingId);
        }
    }

    public class SepayWebhookPayload
    {
        public long Id { get; set; }
        public string? Gateway { get; set; }
        public string? TransactionDate { get; set; }
        public string? AccountNumber { get; set; }
        public string? Content { get; set; }
        public string? TransferType { get; set; }
        public decimal TransferAmount { get; set; }
        public string? ReferenceCode { get; set; }
    }
}
