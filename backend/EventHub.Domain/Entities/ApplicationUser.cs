using System;
using System.Collections.Generic;

namespace EventHub.Domain.Entities
{
    public class ApplicationUser
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? AvatarUrl { get; set; }
        public string Password { get; set; } = "1234567";
        public string UserRole { get; set; } = "Customer"; // Customer | Provider | Admin
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    }
}
