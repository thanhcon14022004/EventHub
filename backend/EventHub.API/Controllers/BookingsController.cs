using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EventHub.Domain.Entities;
using EventHub.Infrastructure.Data;

namespace EventHub.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BookingsController : ControllerBase
    {
        private readonly EventHubDbContext _context;

        public BookingsController(EventHubDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// GET /api/bookings/my - Lấy danh sách đơn đặt của khách hàng
        /// </summary>
        [HttpGet("my")]
        public async Task<IActionResult> GetMyBookings()
        {
            var bookings = await _context.Bookings
                .OrderByDescending(b => b.CreatedAt)
                .ToListAsync();

            return Ok(bookings);
        }

        /// <summary>
        /// GET /api/bookings/{id} - Lấy chi tiết đơn đặt
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetBookingById(Guid id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null)
            {
                return NotFound(new { message = "Không tìm thấy đơn đặt yêu cầu." });
            }

            return Ok(booking);
        }

        /// <summary>
        /// POST /api/bookings - Tạo đơn đặt dịch vụ mới từ khách hàng
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateBooking([FromBody] CreateBookingRequest request)
        {
            if (request == null)
            {
                return BadRequest(new { message = "Dữ liệu yêu cầu không hợp lệ." });
            }

            var now = DateTime.UtcNow;
            var bookingCode = string.IsNullOrWhiteSpace(request.BookingCode)
                ? $"EH-{DateTime.Now:yyyyMMdd}-{new Random().Next(100, 999)}"
                : request.BookingCode;

            var booking = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = bookingCode,
                ServiceId = request.ServiceId != Guid.Empty ? request.ServiceId : Guid.NewGuid(),
                PackageId = request.PackageId,
                CustomerId = request.CustomerId != Guid.Empty ? request.CustomerId : Guid.NewGuid(),
                ProviderId = request.ProviderId != Guid.Empty ? request.ProviderId : Guid.NewGuid(),
                EventDate = request.EventDate != default ? request.EventDate : DateTime.Today.AddDays(7),
                EventAddress = request.EventAddress ?? string.Empty,
                City = request.City ?? "Hà Nội",
                GuestCount = request.GuestCount > 0 ? request.GuestCount : 100,
                SpecialRequirements = request.SpecialRequirements,
                PackageNameSnapshot = request.PackageNameSnapshot ?? "Gói Tiêu Chuẩn",
                PackagePriceSnapshot = request.PackagePriceSnapshot > 0 ? request.PackagePriceSnapshot : 15000000m,
                TotalAmount = request.TotalAmount > 0 ? request.TotalAmount : 15000000m,
                Status = "PendingProviderApproval",
                CreatedAt = now,
                StatusUpdatedAt = now
            };

            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetBookingById), new { id = booking.Id }, booking);
        }

        /// <summary>
        /// POST /api/bookings/{id}/cancel - Khách hàng hủy đơn đặt
        /// </summary>
        [HttpPost("{id}/cancel")]
        public async Task<IActionResult> CancelBooking(Guid id, [FromBody] CancelBookingRequest? request)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null)
            {
                return NotFound(new { message = "Không tìm thấy đơn đặt." });
            }

            booking.Status = "Cancelled";
            booking.CancellationReason = request?.Reason ?? "Khách hàng hủy đơn";
            booking.StatusUpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã hủy đơn đặt thành công.", booking });
        }

        /// <summary>
        /// DELETE /api/bookings/{id} - Xóa vĩnh viễn đơn đặt
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteBooking(Guid id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null)
            {
                return NotFound(new { message = "Không tìm thấy đơn đặt để xóa." });
            }

            _context.Bookings.Remove(booking);
            await _context.SaveChangesAsync();
            return Ok(new { success = true, message = "Đã xóa đơn đặt thành công." });
        }
    }

    [ApiController]
    [Route("api/provider/bookings")]
    public class ProviderBookingsController : ControllerBase
    {
        private readonly EventHubDbContext _context;

        public ProviderBookingsController(EventHubDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// GET /api/provider/bookings - Danh sách đơn đặt của nhà cung cấp
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetProviderBookings()
        {
            var bookings = await _context.Bookings
                .OrderByDescending(b => b.CreatedAt)
                .ToListAsync();

            return Ok(bookings);
        }

        /// <summary>
        /// POST /api/provider/bookings/{id}/accept - Nhà cung cấp duyệt đơn
        /// </summary>
        [HttpPost("{id}/accept")]
        public async Task<IActionResult> AcceptBooking(Guid id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return NotFound(new { message = "Không tìm thấy đơn đặt." });

            booking.Status = "Accepted";
            booking.StatusUpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã duyệt đơn đặt thành công.", booking });
        }

        /// <summary>
        /// POST /api/provider/bookings/{id}/reject - Nhà cung cấp từ chối đơn
        /// </summary>
        [HttpPost("{id}/reject")]
        public async Task<IActionResult> RejectBooking(Guid id, [FromBody] RejectBookingRequest? request)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return NotFound(new { message = "Không tìm thấy đơn đặt." });

            booking.Status = "Rejected";
            booking.RejectionReason = request?.RejectionReason ?? "Nhà cung cấp không thể tiếp nhận thời điểm này";
            booking.StatusUpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã từ chối đơn đặt.", booking });
        }

        /// <summary>
        /// POST /api/provider/bookings/{id}/complete - Đánh dấu hoàn thành
        /// </summary>
        [HttpPost("{id}/complete")]
        public async Task<IActionResult> CompleteBooking(Guid id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return NotFound(new { message = "Không tìm thấy đơn đặt." });

            booking.Status = "Completed";
            booking.StatusUpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã hoàn thành đơn đặt.", booking });
        }
    }

    [ApiController]
    [Route("api/payments")]
    public class PaymentsController : ControllerBase
    {
        private readonly EventHubDbContext _context;

        public PaymentsController(EventHubDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// POST /api/payments/checkout - Thanh toán gộp nhiều đơn hoặc đơn lẻ
        /// </summary>
        [HttpPost("checkout")]
        public async Task<IActionResult> BulkCheckout([FromBody] BulkCheckoutRequest request)
        {
            if (request == null || request.BookingIds == null || !request.BookingIds.Any())
            {
                return BadRequest(new { message = "Vui lòng chọn ít nhất 1 đơn đặt để thanh toán." });
            }

            var matchingBookings = await _context.Bookings
                .Where(b => request.BookingIds.Contains(b.Id.ToString()) || request.BookingIds.Contains(b.BookingCode))
                .ToListAsync();

            var now = DateTime.UtcNow;
            foreach (var b in matchingBookings)
            {
                b.Status = "Confirmed";
                b.PaymentGateway = request.PaymentGateway ?? "VNPay";
                b.StatusUpdatedAt = now;
            }

            await _context.SaveChangesAsync();

            var totalAmount = matchingBookings.Sum(b => b.TotalAmount);
            var paymentCode = $"PAY-{DateTime.Now:yyyyMMdd}-{new Random().Next(1000, 9999)}";

            return Ok(new
            {
                success = true,
                message = $"Đã thanh toán thành công {matchingBookings.Count} đơn đặt dịch vụ.",
                paymentCode,
                totalAmount,
                gateway = request.PaymentGateway ?? "VNPay",
                settledBookingCount = matchingBookings.Count,
                bookingIds = matchingBookings.Select(b => b.Id).ToList()
            });
        }
    }

    public class CreateBookingRequest
    {
        public string? BookingCode { get; set; }
        public Guid ServiceId { get; set; }
        public Guid? PackageId { get; set; }
        public Guid CustomerId { get; set; }
        public Guid ProviderId { get; set; }
        public DateTime EventDate { get; set; }
        public string? EventAddress { get; set; }
        public string? City { get; set; }
        public int GuestCount { get; set; }
        public string? SpecialRequirements { get; set; }
        public string? PackageNameSnapshot { get; set; }
        public decimal PackagePriceSnapshot { get; set; }
        public decimal TotalAmount { get; set; }
        public string? CustomerName { get; set; }
        public string? CustomerPhone { get; set; }
    }

    public class CancelBookingRequest
    {
        public string? Reason { get; set; }
    }

    public class RejectBookingRequest
    {
        public string? RejectionReason { get; set; }
    }

    public class BulkCheckoutRequest
    {
        public List<string> BookingIds { get; set; } = new List<string>();
        public string? PaymentGateway { get; set; }
    }
}
