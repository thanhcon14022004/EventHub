using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using EventHub.Domain.Entities;
using EventHub.Infrastructure.Data;

namespace EventHub.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly EventHubDbContext _context;
        private readonly ILogger<UsersController> _logger;

        public UsersController(EventHubDbContext context, ILogger<UsersController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// GET /api/users - Lấy danh sách người dùng (có thể lọc theo role: Customer, Provider, Admin)
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetUsers([FromQuery] string? role)
        {
            var query = _context.Users.AsQueryable();

            if (!string.IsNullOrWhiteSpace(role))
            {
                query = query.Where(u => u.UserRole.ToLower() == role.Trim().ToLower());
            }

            var users = await query
                .OrderBy(u => u.UserRole)
                .ThenBy(u => u.FullName)
                .Select(u => new
                {
                    u.Id,
                    u.FullName,
                    u.Email,
                    u.PhoneNumber,
                    u.AvatarUrl,
                    u.UserRole,
                    u.IsActive,
                    u.CreatedAt,
                    u.UpdatedAt
                })
                .ToListAsync();

            return Ok(users);
        }

        /// <summary>
        /// GET /api/users/{id} - Lấy chi tiết thông tin người dùng theo Id
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(Guid id)
        {
            var user = await _context.Users
                .Where(u => u.Id == id)
                .Select(u => new
                {
                    u.Id,
                    u.FullName,
                    u.Email,
                    u.PhoneNumber,
                    u.AvatarUrl,
                    u.UserRole,
                    u.IsActive,
                    u.CreatedAt,
                    u.UpdatedAt
                })
                .FirstOrDefaultAsync();

            if (user == null)
            {
                return NotFound(new { message = $"Không tìm thấy người dùng với Id: {id}" });
            }

            return Ok(user);
        }

        /// <summary>
        /// GET /api/users/stats - Thống kê số lượng người dùng theo từng Role
        /// </summary>
        [HttpGet("stats")]
        public async Task<IActionResult> GetUserStats()
        {
            var totalUsers = await _context.Users.CountAsync();
            var totalCustomers = await _context.Users.CountAsync(u => u.UserRole == "Customer");
            var totalProviders = await _context.Users.CountAsync(u => u.UserRole == "Provider");
            var totalAdmins = await _context.Users.CountAsync(u => u.UserRole == "Admin");

            return Ok(new
            {
                TotalUsers = totalUsers,
                Customers = totalCustomers,
                Providers = totalProviders,
                Admins = totalAdmins
            });
        }

        /// <summary>
        /// PUT /api/users/{id}/toggle-status - Khóa hoặc mở khóa tài khoản người dùng
        /// </summary>
        [HttpPut("{id}/toggle-status")]
        public async Task<IActionResult> ToggleUserStatus(Guid id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return NotFound(new { message = $"Không tìm thấy người dùng với Id: {id}" });
            }

            user.IsActive = !user.IsActive;
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = user.IsActive ? "Tài khoản đã được kích hoạt thành công." : "Tài khoản đã bị tạm khóa.",
                userId = user.Id,
                isActive = user.IsActive,
                updatedAt = user.UpdatedAt
            });
        }

        /// <summary>
        /// POST /api/users/seed - Kích hoạt nạp lại dữ liệu người dùng mẫu
        /// </summary>
        [HttpPost("seed")]
        public IActionResult SeedUsers()
        {
            try
            {
                DataSeeder.SeedUsers(_context, _logger);
                return Ok(new
                {
                    message = "Nạp dữ liệu mẫu vào bảng Users thành công!",
                    totalCount = _context.Users.Count()
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi nạp dữ liệu Users.");
                return StatusCode(500, new { message = "Lỗi khi nạp dữ liệu Users", error = ex.Message });
            }
        }
    }
}
