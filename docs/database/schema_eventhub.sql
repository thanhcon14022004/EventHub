-- =======================================================================
-- EventHub - Database Initialization Script for Microsoft SQL Server
-- Database Name: EventHubDb
-- =======================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'EventHubDb')
BEGIN
    CREATE DATABASE EventHubDb;
END
GO

USE EventHubDb;
GO

-- 1. Bảng Users (Khách hàng & Nhà cung cấp)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        FullName NVARCHAR(255) NOT NULL,
        Email NVARCHAR(255) NOT NULL UNIQUE,
        Password NVARCHAR(255) NOT NULL DEFAULT '1234567',
        PhoneNumber NVARCHAR(20) NULL,
        AvatarUrl NVARCHAR(500) NULL,
        UserRole NVARCHAR(50) NOT NULL DEFAULT 'Customer', -- Customer | Provider | Admin
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- 2. Bảng Services (Dịch vụ sự kiện)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Services')
BEGIN
    CREATE TABLE Services (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        ProviderId UNIQUEIDENTIFIER NOT NULL,
        CategoryId UNIQUEIDENTIFIER NOT NULL,
        Title NVARCHAR(255) NOT NULL,
        Description NVARCHAR(MAX) NULL,
        City NVARCHAR(100) NOT NULL,
        BasePrice DECIMAL(18, 2) NOT NULL,
        ApprovalStatus NVARCHAR(50) NOT NULL DEFAULT 'Approved',
        IsActive BIT NOT NULL DEFAULT 1,
        RatingAverage DECIMAL(3, 2) NOT NULL DEFAULT 5.0,
        TotalReviews INT NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- 3. Bảng Bookings (Đơn đặt dịch vụ)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Bookings')
BEGIN
    CREATE TABLE Bookings (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        BookingCode NVARCHAR(50) NOT NULL UNIQUE,
        CustomerId UNIQUEIDENTIFIER NOT NULL,
        ProviderId UNIQUEIDENTIFIER NOT NULL,
        ServiceId UNIQUEIDENTIFIER NOT NULL,
        PackageId UNIQUEIDENTIFIER NULL,
        EventDate DATETIME2 NOT NULL,
        StartTimeUtc DATETIME2 NULL,
        EndTimeUtc DATETIME2 NULL,
        EventAddress NVARCHAR(500) NOT NULL,
        City NVARCHAR(100) NOT NULL,
        GuestCount INT NOT NULL DEFAULT 100,
        SpecialRequirements NVARCHAR(MAX) NULL,
        PackageNameSnapshot NVARCHAR(255) NOT NULL,
        PackagePriceSnapshot DECIMAL(18, 2) NOT NULL,
        TotalAmount DECIMAL(18, 2) NOT NULL,
        Status NVARCHAR(50) NOT NULL DEFAULT 'PendingProviderApproval', -- PendingProviderApproval, Accepted, Rejected, Confirmed, Completed, Cancelled

        PaymentGateway NVARCHAR(50) NULL,
        RejectionReason NVARCHAR(MAX) NULL,
        CancellationReason NVARCHAR(MAX) NULL,
        CancelledByUserId UNIQUEIDENTIFIER NULL,
        StatusUpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- 4. Bảng Payments (Lịch sử giao dịch & Gộp thanh toán)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Payments')
BEGIN
    CREATE TABLE Payments (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        PaymentCode NVARCHAR(50) NOT NULL UNIQUE,
        CustomerId UNIQUEIDENTIFIER NOT NULL,
        TotalAmount DECIMAL(18, 2) NOT NULL,
        Currency NVARCHAR(10) NOT NULL DEFAULT 'VND',
        PaymentGateway NVARCHAR(50) NOT NULL, -- VNPay | MoMo | MockDevelopment
        Status NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending | Succeeded | Failed | Cancelled
        GatewayTransactionNo NVARCHAR(100) NULL,
        GatewayMessage NVARCHAR(255) NULL,
        PaidAt DATETIME2 NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- 5. Seed dữ liệu mẫu bảng Users (Admin, Providers, Customers)
IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'customer@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES 
        -- Admins
        ('33333333-3333-3333-3333-333333333333', N'Quản trị viên Hệ thống', 'admin@eventhub.vn', '0912345678', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 'Admin', 1, DATEADD(month, -6, GETUTCDATE()), GETUTCDATE()),
        ('33333333-3333-3333-3333-333333333334', N'Hà Trung Thành (Super Admin)', 'admin.ha@eventhub.vn', '0988776655', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', 'Admin', 1, DATEADD(month, -6, GETUTCDATE()), GETUTCDATE()),
        ('33333333-3333-3333-3333-333333333335', N'Bộ phận Hỗ trợ EventHub', 'support@eventhub.vn', '19006868', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150', 'Admin', 1, DATEADD(month, -5, GETUTCDATE()), GETUTCDATE()),

        -- Providers
        ('22222222-2222-2222-2222-222222222222', N'Ánh Dương Wedding & Decor', 'provider@eventhub.vn', '0987654321', 'https://images.unsplash.com/photo-1519741497674-611481863552?w=150', 'Provider', 1, DATEADD(month, -4, GETUTCDATE()), GETUTCDATE()),
        ('22222222-2222-2222-2222-222222222223', N'Glow Media & Studio', 'media.glow@eventhub.vn', '0933112233', 'https://images.unsplash.com/photo-1554048612-b6a482bc67e5?w=150', 'Provider', 1, DATEADD(month, -4, GETUTCDATE()), GETUTCDATE()),
        ('22222222-2222-2222-2222-222222222224', N'Vibe Audio & Lighting Systems', 'sound.vibe@eventhub.vn', '0911224466', 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=150', 'Provider', 1, DATEADD(month, -3, GETUTCDATE()), GETUTCDATE()),
        ('22222222-2222-2222-2222-222222222225', N'Lotus Banquet & Event Catering', 'catering.lotus@eventhub.vn', '0944556677', 'https://images.unsplash.com/photo-1555244162-803834f70033?w=150', 'Provider', 1, DATEADD(month, -3, GETUTCDATE()), GETUTCDATE()),
        ('22222222-2222-2222-2222-222222222226', N'MC Minh Trí - MC Song Ngữ', 'mc.minhtri@eventhub.vn', '0909988776', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'Provider', 1, DATEADD(month, -2, GETUTCDATE()), GETUTCDATE()),
        ('22222222-2222-2222-2222-222222222227', N'Blossom Floral & Design', 'flower.blossom@eventhub.vn', '0977889900', 'https://images.unsplash.com/photo-1561181286-d3fee7d55364?w=150', 'Provider', 1, DATEADD(month, -2, GETUTCDATE()), GETUTCDATE()),
        ('22222222-2222-2222-2222-222222222228', N'ProStage Event & Led Wall', 'stage.pro@eventhub.vn', '0966554433', 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=150', 'Provider', 1, DATEADD(month, -1, GETUTCDATE()), GETUTCDATE()),

        -- Customers
        ('11111111-1111-1111-1111-111111111111', N'Khách hàng Demo', 'customer@eventhub.vn', '0901234567', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', 'Customer', 1, DATEADD(month, -4, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111112', N'Nguyễn Văn An', 'nguyen.van.an@gmail.com', '0913579246', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', 'Customer', 1, DATEADD(day, -45, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111113', N'Trần Thị Mai', 'tran.thi.mai@gmail.com', '0924681357', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 'Customer', 1, DATEADD(day, -40, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111114', N'Lê Hoàng Nam', 'le.hoang.nam@gmail.com', '0936912151', 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150', 'Customer', 1, DATEADD(day, -35, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111115', N'Phạm Quỳnh Nga', 'pham.quynh.nga@gmail.com', '0948123789', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150', 'Customer', 1, DATEADD(day, -30, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111116', N'Hoàng Đức Thắng', 'hoang.duc.thang@gmail.com', '0961234890', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 'Customer', 1, DATEADD(day, -25, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111117', N'Vũ Thu Trang', 'vu.thu.trang@gmail.com', '0973456123', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150', 'Customer', 1, DATEADD(day, -20, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111118', N'Đặng Tuấn Kiệt', 'dang.tuan.kiet@gmail.com', '0984567234', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150', 'Customer', 1, DATEADD(day, -15, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111119', N'Bùi Mỹ Linh', 'bui.my.linh@gmail.com', '0915678345', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 'Customer', 1, DATEADD(day, -10, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111120', N'Đỗ Gia Huy', 'do.gia.huy@gmail.com', '0926789456', 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150', 'Customer', 1, DATEADD(day, -7, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111121', N'Ngô Phương Thảo', 'ngo.phuong.thao@gmail.com', '0937890567', 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150', 'Customer', 1, DATEADD(day, -3, GETUTCDATE()), GETUTCDATE()),
        ('11111111-1111-1111-1111-111111111122', N'Công ty CP FPT Software', 'fpt.software@eventhub.vn', '02473007300', 'https://images.unsplash.com/photo-1577962917302-cd874c4e31d2?w=150', 'Customer', 1, DATEADD(day, -1, GETUTCDATE()), GETUTCDATE());
END
GO

-- 6. Seed dữ liệu mẫu bảng Bookings (Đã liên kết đúng CustomerId và ProviderId)
IF NOT EXISTS (SELECT * FROM Bookings WHERE BookingCode = 'EH-20261016-001')
BEGIN
    INSERT INTO Bookings (
        Id, BookingCode, CustomerId, ProviderId, ServiceId, 
        EventDate, EventAddress, City, GuestCount, SpecialRequirements,
        PackageNameSnapshot, PackagePriceSnapshot, TotalAmount, 
        Status, CreatedAt, StatusUpdatedAt
    )
    VALUES (
        NEWID(), 'EH-20261016-001', 
        '11111111-1111-1111-1111-111111111111', -- Khách hàng Demo
        '22222222-2222-2222-2222-222222222222', -- Ánh Dương Wedding & Decor
        NEWID(),
        DATEADD(day, 4, GETDATE()), N'123 Hoàng Mai, Hà Nội', N'Hà Nội', 120, N'Khách yêu cầu bổ sung 2 trụ hoa tươi ở lối đi',
        N'Gói Tiêu Chuẩn (Rustic Decor)', 15000000, 15000000,
        'PendingProviderApproval', DATEADD(hour, -4, GETUTCDATE()), DATEADD(hour, -4, GETUTCDATE())
    );

    INSERT INTO Bookings (
        Id, BookingCode, CustomerId, ProviderId, ServiceId, 
        EventDate, EventAddress, City, GuestCount, SpecialRequirements,
        PackageNameSnapshot, PackagePriceSnapshot, TotalAmount, 
        Status, CreatedAt, StatusUpdatedAt
    )
    VALUES (
        NEWID(), 'EH-20261010-004', 
        '11111111-1111-1111-1111-111111111111', -- Khách hàng Demo
        '22222222-2222-2222-2222-222222222223', -- Glow Media
        NEWID(),
        DATEADD(day, 1, GETDATE()), N'Khách sạn JW Marriott, Hà Nội', N'Hà Nội', 80, N'Cần quay 4K và giao clip highlight 60 giây',
        N'Gói Phóng Sự HD', 8500000, 8500000,
        'Accepted', DATEADD(day, -2, GETUTCDATE()), DATEADD(day, -2, GETUTCDATE())
    );

    INSERT INTO Bookings (
        Id, BookingCode, CustomerId, ProviderId, ServiceId, 
        EventDate, EventAddress, City, GuestCount, SpecialRequirements,
        PackageNameSnapshot, PackagePriceSnapshot, TotalAmount, 
        Status, CreatedAt, StatusUpdatedAt
    )
    VALUES (
        NEWID(), 'EH-20261012-008', 
        '11111111-1111-1111-1111-111111111112', -- Nguyễn Văn An
        '22222222-2222-2222-2222-222222222224', -- Vibe Sound
        NEWID(),
        DATEADD(day, 2, GETDATE()), N'Trung tâm Hội nghị Quốc Gia, Hà Nội', N'Hà Nội', 200, N'Cần 4 mic không dây và 2 loa sub',
        N'Gói Hội Trường 200 Khách', 6000000, 6000000,
        'Accepted', DATEADD(day, -3, GETUTCDATE()), DATEADD(day, -3, GETUTCDATE())
    );
END
GO

-- 7. Truy vấn kiểm tra dữ liệu
SELECT 'Users' AS TableName, COUNT(*) AS TotalRecords FROM Users;
SELECT 'Bookings' AS TableName, COUNT(*) AS TotalRecords FROM Bookings;
SELECT Id, FullName, Email, PhoneNumber, UserRole, IsActive FROM Users ORDER BY CreatedAt ASC;
GO
