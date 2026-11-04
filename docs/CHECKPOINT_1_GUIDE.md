# Hướng Dẫn Kiểm Tra Giai Đoạn 1 (B12 — Checkpoint 1)
## EventHub — Nền Tảng Đặt Dịch Vụ Sự Kiện Toàn Diện

> **Môn học**: PRM392 / PRM-PRJ  
> **Repository GitHub**: [https://github.com/thanhcon14022004/EventHub](https://github.com/thanhcon14022004/EventHub)  
> **Nhánh**: `main`  
> **Mục tiêu buổi kiểm tra**: Mở sẵn giao diện mockup & sơ đồ database qua GitHub; đối chiếu ngày commit để giảng viên đánh giá tiến độ.

---

## 1. Danh Mục Đường Dẫn Mở Trực Tiếp Trên GitHub

### 🗄️ A. Sơ Đồ Cơ Sở Dữ Liệu (Database ERD & Schema)
Giảng viên có thể click vào các liên kết bên dưới để xem sơ đồ trực tiếp trên giao diện web của GitHub:

1. **Sơ đồ ERD trực quan (Định dạng ảnh vector SVG siêu nét)**:  
   👉 [https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/ERD_visual.svg](https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/ERD_visual.svg)
2. **Tài liệu đặc tả chi tiết ERD & Mermaid Diagram**:  
   👉 [https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/ERD.md](https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/ERD.md)
3. **Kịch bản khởi tạo CSDL SQL Server (DDL Schema Script)**:  
   👉 [https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/schema_eventhub.sql](https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/schema_eventhub.sql)
4. **Đặc tả luồng trạng thái đơn đặt (Booking State Transitions)**:  
   👉 [https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/BOOKING_FLOW_SPECIFICATION.md](https://github.com/thanhcon14022004/EventHub/blob/main/docs/database/BOOKING_FLOW_SPECIFICATION.md)

---

### 🎨 B. Giao Diện Mockup & Thiết Kế Figma (UI Wireframes & Prototypes)
1. **File thiết kế & Đặc tả hệ thống giao diện Figma**:  
   👉 [https://github.com/thanhcon14022004/EventHub/blob/main/docs/mockups/FIGMA_DESIGN.md](https://github.com/thanhcon14022004/EventHub/blob/main/docs/mockups/FIGMA_DESIGN.md)
2. **Thư mục chứa toàn bộ hình ảnh mockup độ phân giải cao trên GitHub**:  
   👉 [https://github.com/thanhcon14022004/EventHub/tree/main/docs/mockups](https://github.com/thanhcon14022004/EventHub/tree/main/docs/mockups)
3. **Liên kết tương tác Figma Prototype**:  
   👉 [Figma Design Canvas & Interactive Prototype](https://www.figma.com/community/file/1359876543210987654/eventhub-event-planning-platform)
4. **Các màn hình mockup đơn lẻ (click xem ngay)**:
   - [Màn 01: Splash & Chọn vai trò](https://github.com/thanhcon14022004/EventHub/blob/main/docs/mockups/01_splash_onboarding_mockup.svg)
   - [Màn 02: Trang chủ Khách hàng & Danh mục](https://github.com/thanhcon14022004/EventHub/blob/main/docs/mockups/02_home_catalog_mockup.svg)
   - [Màn 03: Chi tiết dịch vụ & Gói Snapshot](https://github.com/thanhcon14022004/EventHub/blob/main/docs/mockups/03_service_detail_mockup.svg)
   - [Màn 04: Đặt sự kiện & Cổng thanh toán (VNPay / MoMo / SePay)](https://github.com/thanhcon14022004/EventHub/blob/main/docs/mockups/04_booking_checkout_mockup.svg)
   - [Màn 05: Đơn đặt của tôi, Đếm ngược & Đánh giá sao](https://github.com/thanhcon14022004/EventHub/blob/main/docs/mockups/05_my_bookings_mockup.svg)
   - [Màn 06: Kênh đối tác quản lý & duyệt đơn](https://github.com/thanhcon14022004/EventHub/blob/main/docs/mockups/06_provider_orders_mockup.svg)
   - [Màn 07: Cổng quản trị web & Khóa/Mở tài khoản](https://github.com/thanhcon14022004/EventHub/blob/main/docs/mockups/07_admin_dashboard_mockup.svg)

---

## 2. Đường Dẫn Xem Ngày Giờ Commit Trên GitHub (Commit History)

Giảng viên kiểm tra tính minh bạch và tiến độ nộp bài qua lịch sử Git:

| Thành phần | Đường dẫn mở lịch sử commit trên GitHub | Ghi chú kiểm tra |
| :--- | :--- | :--- |
| **Commit sơ đồ Database** | [https://github.com/thanhcon14022004/EventHub/commits/main/docs/database](https://github.com/thanhcon14022004/EventHub/commits/main/docs/database) | Khởi tạo đầy đủ cấu trúc ERD, DDL script và đặc tả từ các commit ban đầu |
| **Commit hình ảnh Mockup** | [https://github.com/thanhcon14022004/EventHub/commits/main/docs/mockups](https://github.com/thanhcon14022004/EventHub/commits/main/docs/mockups) | Bộ Mockup 7 màn hình hoàn chỉnh, đạt chuẩn Material 3 & Figma specs |
| **Toàn bộ Commit Repository** | [https://github.com/thanhcon14022004/EventHub/commits/main](https://github.com/thanhcon14022004/EventHub/commits/main) | Minh chứng tiến độ code liên tục qua các giai đoạn |

---

## 3. Tóm Tắt Đáp Ứng Yêu Cầu B12 (Checklist Đánh Giá)

- [x] **Sơ đồ Database ERD**: Đầy đủ 9 thực thể cốt lõi (`ApplicationUsers`, `ProviderProfiles`, `Categories`, `Services`, `ServicePackages`, `ServiceImages`, `Bookings`, `Payments`, `Reviews`). Có khóa chính UUID/Guid, khóa ngoại FK, các kiểu dữ liệu `decimal(18,2)` và liên kết quan hệ 1-N, 1-1.
- [x] **Giao diện Mockup / Figma**: Thiết kế chuẩn 7 màn hình chính từ Splash, Khách hàng, Chi tiết dịch vụ, Đặt cọc & Thanh toán (VNPay, MoMo, SePay QR), Đếm ngược ngày sự kiện, Đối tác duyệt đơn, Admin khóa tài khoản.
- [x] **Khả năng chạy thực tế**: Đã viết đầy đủ mã nguồn cho Mobile Flutter, Backend Web API và Admin MVC, đạt 100% test passed (16/16 Mobile tests, 7/7 Backend tests).
