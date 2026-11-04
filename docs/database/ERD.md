# EventHub — Database Schema & Entity Relationship Design (ERD)

## 1. Overview

The EventHub database runs on **Microsoft SQL Server** and is managed via **Entity Framework Core 8 Code-First migrations**. All primary keys are `Guid` (UUID) or normalized unique codes. Currency columns use `decimal(18,2)`. All timestamps use UTC (`DateTime`).

---

## 2. Visual & Mermaid Entity-Relationship Diagram (ERD)

### 2.1 Sơ đồ Trực Quan Độ Nét Cao (High-Resolution Diagram)
> **Xem file ảnh gốc trên GitHub**: [`docs/database/ERD_visual.svg`](https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/ERD_visual.svg)

![EventHub Database ERD](https://raw.githubusercontent.com/thanhcon14022004/EventHub/main/docs/database/ERD_visual.svg)

### 2.2 Sơ đồ Mermaid ERD Code

```mermaid
erDiagram
    ApplicationUser ||--o| ProviderProfile : "owns"
    ApplicationUser ||--o{ Booking : "books as Customer"
    ApplicationUser ||--o{ Payment : "initiates"
    ApplicationUser ||--o{ Review : "submits"
    ApplicationUser ||--o{ Notification : "receives"
    ApplicationUser ||--o{ Conversation : "participates (customer/provider)"
    ApplicationUser ||--o{ Message : "sends"
    ApplicationUser ||--o{ AuditLog : "triggers"

    ProviderProfile ||--o{ Service : "offers"
    ProviderProfile ||--o{ ProviderAvailability : "configures"
    ProviderProfile ||--o{ Booking : "receives as Provider"

    Category ||--o{ Service : "classifies"

    Service ||--o{ ServiceImage : "has images"
    Service ||--o{ ServicePackage : "has packages"
    Service ||--o{ Booking : "booked under"
    Service ||--o{ Review : "reviewed under"

    Payment ||--|{ PaymentItem : "includes in payment batch"
    Booking ||--o{ PaymentItem : "settled via"
    Booking ||--o| Review : "has completed review"
    Booking ||--o| Conversation : "associated conversation"

    Payment ||--o{ PaymentTransaction : "records gateway logs"

    ApplicationUser {
        Guid Id PK
        string FullName
        string Email
        string PhoneNumber
        string AvatarUrl
        string UserRole "Customer | Provider | Admin"
        bool IsActive
        datetime CreatedAt
        datetime UpdatedAt
    }

    ProviderProfile {
        Guid Id PK
        Guid UserId FK
        string BusinessName
        string Bio
        string Address
        string City
        string PhoneNumber
        string ApprovalStatus "Pending | Approved | Rejected"
        string RejectionReason
        decimal RatingAverage
        int TotalReviews
        datetime CreatedAt
        datetime UpdatedAt
    }

    Category {
        Guid Id PK
        string Name
        string Slug
        string Description
        string IconUrl
        bool IsActive
        int DisplayOrder
        datetime CreatedAt
    }

    Service {
        Guid Id PK
        Guid ProviderId FK
        Guid CategoryId FK
        string Title
        string Description
        string City
        decimal BasePrice
        string ApprovalStatus "Draft | PendingApproval | Approved | Rejected | Suspended"
        string RejectionReason
        bool IsActive
        decimal RatingAverage
        int TotalReviews
        datetime CreatedAt
        datetime UpdatedAt
    }

    ServiceImage {
        Guid Id PK
        Guid ServiceId FK
        string ImageUrl
        bool IsPrimary
        int DisplayOrder
        datetime CreatedAt
    }

    ServicePackage {
        Guid Id PK
        Guid ServiceId FK
        string Name
        string Description
        decimal Price
        int DurationHours
        int MaxGuests
        string IncludedFeatures "JSON array"
        bool IsActive
        datetime CreatedAt
    }

    ProviderAvailability {
        Guid Id PK
        Guid ProviderId FK
        Guid ServiceId FK "nullable"
        datetime StartTimeUtc
        datetime EndTimeUtc
        bool IsBlocked
        string Reason
        datetime CreatedAt
    }

    Booking {
        Guid Id PK
        string BookingCode UK
        Guid CustomerId FK
        Guid ProviderId FK
        Guid ServiceId FK
        Guid PackageId FK
        date EventDate
        datetime StartTimeUtc
        datetime EndTimeUtc
        string EventAddress
        string City
        int GuestCount
        string SpecialRequirements
        string PackageNameSnapshot
        decimal PackagePriceSnapshot
        decimal TotalAmount
        string Status "PendingProviderApproval | Accepted | Rejected | AwaitingPayment | Confirmed | InProgress | Completed | Cancelled"
        string RejectionReason
        string CancellationReason
        Guid CancelledByUserId FK "nullable"
        datetime StatusUpdatedAt
        datetime CreatedAt
    }

    Payment {
        Guid Id PK
        string PaymentCode UK
        Guid CustomerId FK
        decimal TotalAmount "Tổng tiền thanh toán của tất cả đơn hàng"
        string Currency "VND"
        string PaymentGateway "VNPay | MoMo | MockDevelopment"
        string Status "Pending | Processing | Succeeded | Failed | Cancelled | Refunded"
        string GatewayTransactionNo
        string GatewayResponseCode
        string GatewayMessage
        datetime PaidAt
        datetime CreatedAt
    }

    PaymentItem {
        Guid Id PK
        Guid PaymentId FK
        Guid BookingId FK
        decimal Amount "Số tiền của từng đơn được gộp thanh toán"
        datetime CreatedAt
    }

    PaymentTransaction {
        Guid Id PK
        Guid PaymentId FK
        string TransactionType "Initiate | Callback | Webhook | Refund"
        string RawPayload
        bool SignatureValid
        datetime ProcessedAt
    }

    Review {
        Guid Id PK
        Guid BookingId FK "unique (1 per completed booking)"
        Guid ServiceId FK
        Guid CustomerId FK
        int Rating "1 to 5"
        string Comment
        string ProviderReply
        bool IsHiddenByAdmin
        string ModerationReason
        datetime CreatedAt
    }

    Conversation {
        Guid Id PK
        Guid CustomerId FK
        Guid ProviderId FK
        Guid BookingId FK "nullable"
        datetime LastMessageAt
        datetime CreatedAt
    }

    Message {
        Guid Id PK
        Guid ConversationId FK
        Guid SenderId FK
        string Content
        bool IsRead
        datetime CreatedAt
    }

    Notification {
        Guid Id PK
        Guid UserId FK
        string Title
        string Body
        string TargetType "Booking | Payment | Review | Service"
        string TargetId
        bool IsRead
        datetime CreatedAt
    }

    AuditLog {
        Guid Id PK
        Guid UserId FK "nullable"
        string Action
        string EntityName
        string EntityId
        string OldValues
        string NewValues
        string IpAddress
        datetime TimestampUtc
    }
```

---

## 3. Key Relationships and Rules

1. **Price Snapshots**: When a customer confirms a booking, the package's name and price at that exact moment are recorded in `PackageNameSnapshot` and `PackagePriceSnapshot`. If the provider subsequently changes package pricing, historical bookings remain unchanged.
2. **Double Booking Prevention**:
   - `ProviderAvailability` tracks explicit blackouts.
   - Any booking in `Accepted`, `AwaitingPayment`, `Confirmed`, or `InProgress` locks that provider's schedule for overlapping time windows `[StartTimeUtc, EndTimeUtc]`.
3. **Review Eligibility**:
   - Customer can only review a booking with `Status == Completed`.
   - `BookingId` is unique in `Review` table (1 booking = max 1 review).
4. **Payment Idempotency**:
   - Gateway callbacks check whether `Payment.Status == Succeeded`. If already succeeded, repeated callbacks log to `PaymentTransaction` and return success without double-crediting or duplicate booking status updates.
5. **Aggregate Payment (Thanh toán tổng tất cả đơn hàng)**:
   - Hệ thống hỗ trợ khách hàng thanh toán lẻ từng đơn hoặc **thanh toán gộp tổng tất cả các đơn hàng** (các đơn ở trạng thái `Accepted` / `AwaitingPayment`) trong 1 lần giao dịch duy nhất.
   - Bảng `Payment` lưu `TotalAmount` là tổng tiền của tất cả các đơn hàng được gộp thanh toán (`TotalAmount = ∑ Booking.TotalAmount`).
   - Bảng `PaymentItem` lưu chi tiết danh sách từng `BookingId` và số tiền tương ứng được thanh toán trong phiên giao dịch đó.
   - Khi thanh toán qua cổng (VNPay/MoMo) thành công (`Payment.Status == Succeeded`), hệ thống tự động cập nhật tất cả các `Booking` có trong `PaymentItem` sang trạng thái `Confirmed` và khóa lịch phục vụ.
