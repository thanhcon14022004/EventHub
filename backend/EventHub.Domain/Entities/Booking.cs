using System;

namespace EventHub.Domain.Entities
{
    public class Booking
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string BookingCode { get; set; } = string.Empty;
        public Guid CustomerId { get; set; }
        public Guid ProviderId { get; set; }
        public Guid ServiceId { get; set; }
        public Guid? PackageId { get; set; }

        public DateTime EventDate { get; set; }
        public DateTime? StartTimeUtc { get; set; }
        public DateTime? EndTimeUtc { get; set; }

        public string EventAddress { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public int GuestCount { get; set; }
        public string? SpecialRequirements { get; set; }

        public string PackageNameSnapshot { get; set; } = string.Empty;
        public decimal PackagePriceSnapshot { get; set; }
        public decimal TotalAmount { get; set; }

        // PendingProviderApproval | Accepted | Rejected | AwaitingPayment | Confirmed | InProgress | Completed | Cancelled
        public string Status { get; set; } = "PendingProviderApproval";

        public string? PaymentGateway { get; set; }
        public string? RejectionReason { get; set; }
        public string? CancellationReason { get; set; }
        public Guid? CancelledByUserId { get; set; }
        public int? Rating { get; set; }
        public string? ReviewComment { get; set; }
        public DateTime? ReviewedAt { get; set; }

        public DateTime StatusUpdatedAt { get; set; } = DateTime.UtcNow;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation
        public virtual ApplicationUser? Customer { get; set; }
        public virtual Service? Service { get; set; }
    }
}
