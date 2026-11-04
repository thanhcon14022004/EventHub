# EventHub — Event Planning and Service Booking Platform

Nền tảng kết nối trực tuyến toàn diện giữa **Khách hàng có nhu cầu tổ chức sự kiện** và **Nhà cung cấp dịch vụ sự kiện chuyên nghiệp** (Trang trí, Quay phim chụp ảnh, Ẩm thực & Catering, Địa điểm & Hội trường).

Dự án phát triển đầy đủ cả 3 thành phần:
1. **Ứng dụng di động (Flutter Mobile)** dành cho Khách hàng & Nhà cung cấp.
2. **Hệ thống Backend REST API (ASP.NET Core Web API .NET 8 & Entity Framework Core 8)** kết nối cơ sở dữ liệu quan hệ **Microsoft SQL Server**.
3. **Cổng thông tin quản trị Web (ASP.NET Core MVC Razor Views)** dành cho Quản trị viên điều hành nền tảng.

---

## 📌 B12 — KIỂM TRA GIAI ĐOẠN 1 (CHECKPOINT 1)

Dành cho Giảng viên / Hội đồng mở kiểm tra trực tiếp qua GitHub:

| Hạng mục kiểm tra | Liên kết xem trực tiếp trên GitHub | Xem lịch sử ngày giờ commit |
| :--- | :--- | :--- |
| **Sơ đồ Database (ERD Trực quan)** | [📊 Xem Sơ đồ ERD SVG](https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/ERD_visual.svg) • [Tài liệu ERD chi tiết](https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/ERD.md) | [🕒 Lịch sử commit Database](https://github.com/thanhcon14022004/EventHub/commits/main/docs/database) |
| **Giao diện Mockup & Figma** | [🎨 Xem Hồ sơ thiết kế Figma & 7 màn hình](https://github.com/thanhcon14022004/EventHub/blob/main/docs/mockups/FIGMA_DESIGN.md) • [Thư mục Mockups](https://github.com/thanhcon14022004/EventHub/tree/main/docs/mockups) | [🕒 Lịch sử commit Mockups](https://github.com/thanhcon14022004/EventHub/commits/main/docs/mockups) |
| **Hướng dẫn chi tiết Check B12** | [📋 Hướng dẫn nghiệm thu Giai đoạn 1](https://github.com/thanhcon14022004/EventHub/blob/main/docs/CHECKPOINT_1_GUIDE.md) | [🕒 Toàn bộ commit repo](https://github.com/thanhcon14022004/EventHub/commits/main) |

---

## 1. Cấu trúc thư mục dự án

```text
EventHub/
├── mobile/                     # Ứng dụng di động Flutter
│   ├── lib/
│   │   ├── core/               # Theme, constants, networking, routing, secure storage
│   │   ├── features/           # Auth, Home, Categories, Services, Bookings, Chat, Notifications, Profile, Provider
│   │   ├── shared/             # Shell navigation, reusable widgets
│   │   ├── app.dart            # Root MaterialApp.router với Riverpod
│   │   └── main.dart           # Điểm khởi chạy Flutter
│   └── test/                   # Flutter automated tests (widget tests, smoke tests)
│
├── backend/                    # Hệ thống ASP.NET Core Web API (.NET 8)
│   ├── EventHub.sln            # Solution file
│   ├── EventHub.API/           # RESTful Web API Controllers, Swagger, Middlewares
│   ├── EventHub.Application/   # Services layer, DTOs, Business Logic, Interfaces
│   ├── EventHub.Domain/        # Domain Entities, Enums, Value Objects
│   ├── EventHub.Infrastructure/# EF Core 8 DbContext, Migrations, Identity, Gateways
│   └── EventHub.Tests/         # Unit & Integration Tests (xUnit)
│
├── admin/                      # Cổng quản trị web (ASP.NET Core MVC .NET 8)
│   └── EventHub.Admin/         # Quản trị viên: duyệt nhà cung cấp, dịch vụ, báo cáo doanh thu
│
├── docs/                       # Tài liệu thiết kế & đặc tả hệ thống
│   ├── UI_FLOW_AND_MOCKUPS.md  # Chi tiết luồng người dùng & bộ ảnh Mockup ứng dụng
│   ├── mockups/                # Toàn bộ hình ảnh Mockup/Screenshots độ phân giải cao
│   ├── database/               # ERD thiết kế cơ sở dữ liệu & State transitions
│   ├── api/                    # Đặc tả REST API Endpoints
│   └── diagrams/               # Kiến trúc & sơ đồ tuần tự
│
└── README.md                   # Hướng dẫn khởi chạy toàn bộ hệ thống
```

---

## 2. Công nghệ sử dụng

### Mobile (Flutter)
- **Flutter 3.47.2** / **Dart 3.13.2**
- **Material 3 Design System** (Deep Purple `#673AB7`, Lavender `#EDE7F6`, bo tròn 16px, trạng thái màu sắc chuẩn)
- **Riverpod 2.6** (`flutter_riverpod`) quản lý trạng thái
- **GoRouter 14** điều hướng đa tầng theo vai trò (Customer Shell & Provider Shell)
- **Dio 5.4** kết nối HTTP RESTful với Auth Interceptor & error formatter
- **Flutter Secure Storage** lưu trữ JWT Token an toàn
- **Shared Preferences** lưu cấu hình thiết bị
- **Intl & Image Picker** định dạng ngày tháng, tiền tệ VND và chọn ảnh upload

### Backend & Database
- **C# / .NET 8 (ASP.NET Core Web API)**
- **Entity Framework Core 8** Code-First Migrations
- **Microsoft SQL Server** (`.\SQLEXPRESS`)
- **ASP.NET Core Identity & JWT Bearer** xác thực & phân quyền RBAC
- **Swagger / OpenAPI** tài liệu hóa API tương tác
- **Tích hợp thanh toán trực tuyến** VNPay Sandbox / MoMo & cơ chế xử lý Webhook Idempotent an toàn chống duplicate.

### Cổng quản trị (Admin Web)
- **ASP.NET Core MVC với Razor Views**
- Dữ liệu trực tiếp từ SQL Server Database qua Application Services.

---

## 3. Hướng dẫn khởi chạy

### Yêu cầu tiên quyết
- .NET 8 SDK trở lên (đã kiểm tra tương thích .NET SDK 10/8).
- Flutter SDK (đã tích hợp tại `C:\Users\thanh\Downloads\flutter_windows_3.47.2-stable\flutter\bin`).
- Microsoft SQL Server (`.\SQLEXPRESS` đang chạy).

---

### Khởi chạy Backend API
```powershell
cd backend\EventHub.API
dotnet run
```
API sẽ khởi chạy tại:
- Swagger UI: `http://localhost:5000/swagger` hoặc `https://localhost:5001/swagger`
- REST API Base URL: `http://localhost:5000/api`

---

### Khởi chạy Cổng quản trị Admin MVC
```powershell
cd admin\EventHub.Admin
dotnet run
```
Truy cập qua trình duyệt: `http://localhost:5100`

---

### Khởi chạy Flutter Mobile App
```powershell
cd mobile
flutter run
```
> **Lưu ý cấu hình kết nối API:**
> - Chạy trên **Android Emulator**: Ứng dụng tự động kết nối qua `http://10.0.2.2:5000/api`.
> - Chạy trên **Windows / Web / iOS**: Ứng dụng tự động kết nối qua `http://localhost:5000/api`.
> - Chạy trên **Thiết bị thật (Physical Device)**: Đổi IP máy chủ trong `lib/core/constants/api_constants.dart` sang địa chỉ LAN IP (ví dụ: `http://192.168.1.x:5000/api`).

---

## 4. Tài khoản Demo kiểm thử nhanh

Hệ thống có cấu hình sẵn các tài khoản demo tương ứng với 3 vai trò:

| Vai trò | Email | Mật khẩu mặc định | Ghi chú |
| :--- | :--- | :--- | :--- |
| **Khách hàng (Customer)** | `customer@eventhub.vn` | `1234567` | Tìm kiếm, xem dịch vụ, tạo đơn đặt, thanh toán, đánh giá |
| **Nhà cung cấp (Provider)** | `provider@eventhub.vn` | `1234567` | Quản lý gói giá, duyệt/từ chối đơn, cập nhật tiến độ |
| **Quản trị viên (Admin)** | `admin@eventhub.vn` | `1234567` | Duyệt nhà cung cấp, duyệt dịch vụ, xem báo cáo doanh thu |
| *Tất cả các tài khoản khác* | *Theo danh sách bảng Users* | `1234567` | Đồng bộ mật khẩu toàn hệ thống |

---

## 5. Tiến độ triển khai các cột mốc (Milestones)

- [x] **Phase 1 — Phân tích, kiến trúc và khởi tạo nền tảng:**
  - Khảo sát công cụ, SDK Flutter, .NET SDK, SQL Server.
  - Thiết lập cấu trúc Monorepo chuẩn (`mobile`, `backend`, `admin`, `docs`).
  - Thiết kế ERD Cơ sở dữ liệu quan hệ (`docs/database/ERD.md`).
  - Thiết kế State Machine & Rules (`docs/database/state-transitions.md`).
  - Đặc tả RESTful API Contracts (`docs/api/api-spec.md`).
  - Xây dựng giải pháp Backend (.NET 8 solution & 5 projects, build 0 errors).
  - Xây dựng Admin MVC (.NET 8 MVC, build 0 errors).
  - Xây dựng bộ khung Flutter Mobile hoàn chỉnh (Material 3, Riverpod, GoRouter, Dio, SecureStorage, Theme, Customer & Provider Shells, 13 màn hình, tests pass 100%, analyze 0 issues).
- [ ] **Phase 2 — Cơ sở dữ liệu SQL Server & Xác thực Identity JWT**
- [ ] **Phase 3 — Sàn giao dịch dịch vụ sự kiện (Marketplace Services)**
- [ ] **Phase 4 — Hệ thống đặt dịch vụ & xử lý lịch trình (Booking System)**
- [ ] **Phase 5 — Tích hợp thanh toán (VNPay/MoMo) & Đánh giá (Reviews)**
- [ ] **Phase 6 — Cổng quản trị Admin Web & Giao tiếp (Chat & Notifications)**
- [ ] **Phase 7 — Kiểm thử tích hợp toàn diện & Build Android APK**
- [ ] **Phase 8 — Bàn giao tài liệu & Kịch bản nghiệm thu**
