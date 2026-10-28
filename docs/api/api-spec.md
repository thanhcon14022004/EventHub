# EventHub — REST API Specification

All endpoints are prefixed with `/api`. Protected endpoints require standard `Authorization: Bearer <JWT_TOKEN>` header.

## 1. Authentication & Profiles (`/api/auth`)

- `POST /api/auth/register`: Register new customer or provider account.
  - Body: `{ fullName, email, password, phoneNumber, role ("Customer"|"Provider") }`
  - Returns: `{ token, user: { id, fullName, email, role, avatarUrl } }`
- `POST /api/auth/login`: Authenticate existing user.
  - Body: `{ email, password }`
  - Returns: `{ token, user: { id, fullName, email, role, avatarUrl, providerProfileId } }`
- `GET /api/auth/me`: Get current authenticated user profile.
- `PUT /api/auth/profile`: Update user profile (name, phone, avatarUrl).
- `POST /api/auth/change-password`: Change user password.

## 2. Categories (`/api/categories`)

- `GET /api/categories`: Public list of active categories.
- `GET /api/categories/{id}`: Category details.
- `POST /api/admin/categories`: (Admin) Create category.
- `PUT /api/admin/categories/{id}`: (Admin) Update category.
- `DELETE /api/admin/categories/{id}`: (Admin) Toggle or delete category.

## 3. Marketplace Services (`/api/services`)

- `GET /api/services`: Public search & filter approved services.
  - Query parameters: `keyword`, `categoryId`, `city`, `minPrice`, `maxPrice`, `minRating`, `sortBy ("price_asc"|"price_desc"|"rating"|"newest")`, `page`, `pageSize`.
- `GET /api/services/{id}`: Public service details with packages, images, provider info, and recent reviews.
- `GET /api/services/{id}/packages`: Packages for a specific service.
- `GET /api/services/{id}/availability`: Availability calendar / blocked dates for a service.
- `GET /api/services/{id}/reviews`: Reviews for a service with pagination.

## 4. Provider Management (`/api/provider`)

- `GET /api/provider/profile`: Get current provider profile.
- `PUT /api/provider/profile`: Update business bio, address, city.
- `POST /api/provider/apply`: Submit provider verification application.
- `GET /api/provider/services`: List services belonging to current provider.
- `POST /api/provider/services`: Create new service (starts in Draft).
- `PUT /api/provider/services/{id}`: Edit service details.
- `POST /api/provider/services/{id}/submit-for-approval`: Submit service for admin approval.
- `POST /api/provider/services/{id}/images`: Upload service images.
- `DELETE /api/provider/services/{id}/images/{imageId}`: Remove image.
- `POST /api/provider/services/{id}/packages`: Add package to service.
- `PUT /api/provider/services/{id}/packages/{pkgId}`: Update package.
- `DELETE /api/provider/services/{id}/packages/{pkgId}`: Deactivate package.
- `GET /api/provider/availability`: Get provider blackout schedule.
- `POST /api/provider/availability`: Add blackout date/time window.
- `DELETE /api/provider/availability/{id}`: Remove blackout window.
- `GET /api/provider/bookings`: Incoming & active bookings for current provider.
- `POST /api/provider/bookings/{id}/accept`: Provider accepts booking.
- `POST /api/provider/bookings/{id}/reject`: Provider rejects booking `{ rejectionReason }`.
- `POST /api/provider/bookings/{id}/start`: Mark service delivery started.
- `POST /api/provider/bookings/{id}/complete`: Mark service delivery completed.
- `GET /api/provider/reports/revenue`: Provider revenue and stats summary.

## 5. Bookings (`/api/bookings`)

- `POST /api/bookings`: Customer creates booking request.
  - Body: `{ serviceId, packageId, eventDate, startTimeUtc, endTimeUtc, eventAddress, city, guestCount, specialRequirements }`
- `GET /api/bookings/my`: Customer's booking history.
- `GET /api/bookings/{id}`: Booking details with price breakdown and current status.
- `POST /api/bookings/{id}/cancel`: Customer cancels booking `{ reason }`.

## 6. Payments (`/api/payments`)

- `POST /api/payments/checkout`: Create payment record & return Gateway URL (VNPay/MoMo/Mock) supporting single or bulk aggregate booking checkout.
  - Body: `{ bookingIds: string[], paymentGateway ("VNPay"|"MoMo"|"MockDevelopment") }` (Danh sách các mã đơn đặt dịch vụ muốn gộp thanh toán tổng).
  - Returns: `{ paymentId, paymentCode, totalAmount, currency, paymentUrl, items: [{ bookingId, amount }] }`
- `GET /api/payments/pending-summary`: (Customer) Lấy danh sách và tổng số tiền của tất cả các đơn hàng đang chờ thanh toán (`Accepted` / `AwaitingPayment`).
  - Returns: `{ totalPendingBookings, grandTotalAmount, items: [...] }`
- `GET /api/payments/{id}`: Payment status inspection with associated booking items.
- `GET /api/payments/my`: User's transaction history.
- `GET /api/payments/vnpay-return`: Gateway return URL handler (redirects user).
- `POST /api/payments/vnpay-ipn`: Gateway asynchronous webhook with signature verification.
- `POST /api/payments/mock-confirm/{paymentId}`: Development mock payment completion endpoint.

## 7. Reviews (`/api/reviews`)

- `POST /api/reviews`: Submit review for completed booking.
  - Body: `{ bookingId, rating (1-5), comment }`
- `POST /api/reviews/{id}/reply`: Provider replies to a review.

## 8. Chat & Notifications (`/api/conversations`, `/api/notifications`)

- `GET /api/conversations`: List active conversations for current user.
- `POST /api/conversations`: Start conversation between customer & provider.
- `GET /api/conversations/{id}/messages`: Message history.
- `POST /api/conversations/{id}/messages`: Send message `{ content }`.
- `GET /api/notifications`: Get user notifications.
- `PUT /api/notifications/{id}/read`: Mark notification as read.
- `PUT /api/notifications/read-all`: Mark all as read.

## 9. Admin Portal (`/api/admin`)

- `GET /api/admin/dashboard`: Platform KPIs (total revenue, active bookings, users, providers, pending approvals).
- `GET /api/admin/users`: List users with filtering, role, status.
- `PUT /api/admin/users/{id}/toggle-status`: Activate/Deactivate user.
- `GET /api/admin/providers/pending`: List pending provider applications.
- `POST /api/admin/providers/{id}/approve`: Approve provider.
- `POST /api/admin/providers/{id}/reject`: Reject provider `{ reason }`.
- `GET /api/admin/services/pending`: Services awaiting approval.
- `POST /api/admin/services/{id}/approve`: Approve service listing.
- `POST /api/admin/services/{id}/reject`: Reject service listing `{ reason }`.
- `GET /api/admin/bookings`: All bookings across platform.
- `GET /api/admin/payments`: All payments & gateway logs.
- `GET /api/admin/reports/revenue`: Platform revenue aggregated by month/category.
- `GET /api/admin/reports/bookings`: Booking volume & completion rates.
