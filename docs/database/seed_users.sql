-- =======================================================================
-- EventHub - Seed Data Script for Users Table (Bảng Users)
-- Database: EventHubDb
-- =======================================================================

USE EventHubDb;
GO

PRINT N'Bắt đầu nạp dữ liệu mẫu (Seed Data) vào bảng Users...';

-- Đảm bảo cột Password tồn tại trong bảng Users (Mật khẩu mặc định: 1234567)
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('Users') AND name = 'Password'
)
BEGIN
    ALTER TABLE Users ADD Password NVARCHAR(255) NOT NULL DEFAULT '1234567';
END
GO
IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'admin@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '33333333-3333-3333-3333-333333333333',
        N'Quản trị viên Hệ thống',
        'admin@eventhub.vn',
        '0912345678',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        'Admin', 1, DATEADD(month, -6, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'admin.ha@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '33333333-3333-3333-3333-333333333334',
        N'Hà Trung Thành (Super Admin)',
        'admin.ha@eventhub.vn',
        '0988776655',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        'Admin', 1, DATEADD(month, -6, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'support@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '33333333-3333-3333-3333-333333333335',
        N'Bộ phận Hỗ trợ EventHub',
        'support@eventhub.vn',
        '19006868',
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        'Admin', 1, DATEADD(month, -5, GETUTCDATE()), GETUTCDATE()
    );
END

-- 2. TÀI KHOẢN NHÀ CUNG CẤP (Providers)
IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'provider@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '22222222-2222-2222-2222-222222222222',
        N'Ánh Dương Wedding & Decor',
        'provider@eventhub.vn',
        '0987654321',
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=150',
        'Provider', 1, DATEADD(month, -4, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'media.glow@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '22222222-2222-2222-2222-222222222223',
        N'Glow Media & Studio',
        'media.glow@eventhub.vn',
        '0933112233',
        'https://images.unsplash.com/photo-1554048612-b6a482bc67e5?w=150',
        'Provider', 1, DATEADD(month, -4, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'sound.vibe@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '22222222-2222-2222-2222-222222222224',
        N'Vibe Audio & Lighting Systems',
        'sound.vibe@eventhub.vn',
        '0911224466',
        'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=150',
        'Provider', 1, DATEADD(month, -3, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'catering.lotus@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '22222222-2222-2222-2222-222222222225',
        N'Lotus Banquet & Event Catering',
        'catering.lotus@eventhub.vn',
        '0944556677',
        'https://images.unsplash.com/photo-1555244162-803834f70033?w=150',
        'Provider', 1, DATEADD(month, -3, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'mc.minhtri@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '22222222-2222-2222-2222-222222222226',
        N'MC Minh Trí - MC Song Ngữ',
        'mc.minhtri@eventhub.vn',
        '0909988776',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'Provider', 1, DATEADD(month, -2, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'flower.blossom@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '22222222-2222-2222-2222-222222222227',
        N'Blossom Floral & Design',
        'flower.blossom@eventhub.vn',
        '0977889900',
        'https://images.unsplash.com/photo-1561181286-d3fee7d55364?w=150',
        'Provider', 1, DATEADD(month, -2, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'stage.pro@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '22222222-2222-2222-2222-222222222228',
        N'ProStage Event & Led Wall',
        'stage.pro@eventhub.vn',
        '0966554433',
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=150',
        'Provider', 1, DATEADD(month, -1, GETUTCDATE()), GETUTCDATE()
    );
END

-- 3. TÀI KHOẢN KHÁCH HÀNG (Customers)
IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'customer@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111111',
        N'Khách hàng Demo',
        'customer@eventhub.vn',
        '0901234567',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'Customer', 1, DATEADD(month, -4, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'nguyen.van.an@gmail.com')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111112',
        N'Nguyễn Văn An',
        'nguyen.van.an@gmail.com',
        '0913579246',
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        'Customer', 1, DATEADD(day, -45, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'tran.thi.mai@gmail.com')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111113',
        N'Trần Thị Mai',
        'tran.thi.mai@gmail.com',
        '0924681357',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        'Customer', 1, DATEADD(day, -40, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'le.hoang.nam@gmail.com')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111114',
        N'Lê Hoàng Nam',
        'le.hoang.nam@gmail.com',
        '0936912151',
        'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
        'Customer', 1, DATEADD(day, -35, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'pham.quynh.nga@gmail.com')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111115',
        N'Phạm Quỳnh Nga',
        'pham.quynh.nga@gmail.com',
        '0948123789',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        'Customer', 1, DATEADD(day, -30, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'hoang.duc.thang@gmail.com')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111116',
        N'Hoàng Đức Thắng',
        'hoang.duc.thang@gmail.com',
        '0961234890',
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
        'Customer', 1, DATEADD(day, -25, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'vu.thu.trang@gmail.com')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111117',
        N'Vũ Thu Trang',
        'vu.thu.trang@gmail.com',
        '0973456123',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
        'Customer', 1, DATEADD(day, -20, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'dang.tuan.kiet@gmail.com')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111118',
        N'Đặng Tuấn Kiệt',
        'dang.tuan.kiet@gmail.com',
        '0984567234',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        'Customer', 1, DATEADD(day, -15, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'bui.my.linh@gmail.com')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111119',
        N'Bùi Mỹ Linh',
        'bui.my.linh@gmail.com',
        '0915678345',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        'Customer', 1, DATEADD(day, -10, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'do.gia.huy@gmail.com')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111120',
        N'Đỗ Gia Huy',
        'do.gia.huy@gmail.com',
        '0926789456',
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
        'Customer', 1, DATEADD(day, -7, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'ngo.phuong.thao@gmail.com')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111121',
        N'Ngô Phương Thảo',
        'ngo.phuong.thao@gmail.com',
        '0937890567',
        'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
        'Customer', 1, DATEADD(day, -3, GETUTCDATE()), GETUTCDATE()
    );
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'fpt.software@eventhub.vn')
BEGIN
    INSERT INTO Users (Id, FullName, Email, PhoneNumber, AvatarUrl, UserRole, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        '11111111-1111-1111-1111-111111111122',
        N'Công ty CP FPT Software (Ban Sự kiện)',
        'fpt.software@eventhub.vn',
        '02473007300',
        'https://images.unsplash.com/photo-1577962917302-cd874c4e31d2?w=150',
        'Customer', 1, DATEADD(day, -1, GETUTCDATE()), GETUTCDATE()
    );
END

-- Đồng bộ mật khẩu tất cả các tài khoản về 1234567
UPDATE Users SET Password = '1234567' WHERE Password IS NULL OR Password <> '1234567';

PRINT N'Hoàn tất nạp dữ liệu mẫu vào bảng Users (Mật khẩu đồng bộ: 1234567).';

-- Kiểm tra danh sách người dùng vừa thêm kèm Mật khẩu
SELECT 
    Id, 
    FullName, 
    Email, 
    Password,
    PhoneNumber, 
    UserRole, 
    IsActive, 
    CreatedAt 
FROM Users 
ORDER BY 
    CASE UserRole 
        WHEN 'Admin' THEN 1 
        WHEN 'Provider' THEN 2 
        WHEN 'Customer' THEN 3 
        ELSE 4 
    END, 
    CreatedAt ASC;
GO
