using System;
using System.Collections.Generic;

namespace EventHub.Domain.Entities
{
    public class Service
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid ProviderId { get; set; }
        public Guid CategoryId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public decimal BasePrice { get; set; }
        public string ApprovalStatus { get; set; } = "Approved"; // Draft | PendingApproval | Approved | Rejected | Suspended
        public bool IsActive { get; set; } = true;
        public decimal RatingAverage { get; set; } = 5.0m;
        public int TotalReviews { get; set; } = 0;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    }
}
