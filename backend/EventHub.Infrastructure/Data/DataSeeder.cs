using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Extensions.Logging;
using EventHub.Domain.Entities;

namespace EventHub.Infrastructure.Data
{
    public static class DataSeeder
    {
        // Fixed well-known IDs so they match Flutter App demo accounts & foreign keys
        public static readonly Guid DemoCustomerId = Guid.Parse("11111111-1111-1111-1111-111111111111");
        public static readonly Guid DemoProviderId = Guid.Parse("22222222-2222-2222-2222-222222222222");
        public static readonly Guid DemoAdminId    = Guid.Parse("33333333-3333-3333-3333-333333333333");

        public static void SeedAll(EventHubDbContext db, ILogger logger)
        {
            SeedUsers(db, logger);
            SeedBookings(db, logger);
        }

        public static void SeedUsers(EventHubDbContext db, ILogger logger)
        {
            if (db.Users.Any())
            {
                logger.LogInformation("Users table already contains data, skipping seed.");
                return;
            }

            var users = new List<ApplicationUser>
            {
                // ==========================================
                // 1. ADMINS
                // ==========================================
                new ApplicationUser
                {
                    Id = DemoAdminId,
                    FullName = "Quản trị viên Hệ thống",
                    Email = "admin@eventhub.vn",
                    PhoneNumber = "0912345678",
                    AvatarUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150",
                    UserRole = "Admin",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("33333333-3333-3333-3333-333333333334"),
                    FullName = "Hà Trung Thành (Super Admin)",
                    Email = "admin.ha@eventhub.vn",
                    PhoneNumber = "0988776655",
                    AvatarUrl = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
                    UserRole = "Admin",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("33333333-3333-3333-3333-333333333335"),
                    FullName = "Bộ phận Hỗ trợ EventHub",
                    Email = "support@eventhub.vn",
                    PhoneNumber = "19006868",
                    AvatarUrl = "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150",
                    UserRole = "Admin",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-5),
                    UpdatedAt = DateTime.UtcNow
                },

                // ==========================================
                // 2. PROVIDERS
                // ==========================================
                new ApplicationUser
                {
                    Id = DemoProviderId,
                    FullName = "Ánh Dương Wedding & Decor",
                    Email = "provider@eventhub.vn",
                    PhoneNumber = "0987654321",
                    AvatarUrl = "https://images.unsplash.com/photo-1519741497674-611481863552?w=150",
                    UserRole = "Provider",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-4),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("22222222-2222-2222-2222-222222222223"),
                    FullName = "Glow Media & Studio",
                    Email = "media.glow@eventhub.vn",
                    PhoneNumber = "0933112233",
                    AvatarUrl = "https://images.unsplash.com/photo-1554048612-b6a482bc67e5?w=150",
                    UserRole = "Provider",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-4),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("22222222-2222-2222-2222-222222222224"),
                    FullName = "Vibe Audio & Lighting Systems",
                    Email = "sound.vibe@eventhub.vn",
                    PhoneNumber = "0911224466",
                    AvatarUrl = "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=150",
                    UserRole = "Provider",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-3),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("22222222-2222-2222-2222-222222222225"),
                    FullName = "Lotus Banquet & Event Catering",
                    Email = "catering.lotus@eventhub.vn",
                    PhoneNumber = "0944556677",
                    AvatarUrl = "https://images.unsplash.com/photo-1555244162-803834f70033?w=150",
                    UserRole = "Provider",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-3),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("22222222-2222-2222-2222-222222222226"),
                    FullName = "MC Minh Trí - MC Song Ngữ",
                    Email = "mc.minhtri@eventhub.vn",
                    PhoneNumber = "0909988776",
                    AvatarUrl = "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150",
                    UserRole = "Provider",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-2),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("22222222-2222-2222-2222-222222222227"),
                    FullName = "Blossom Floral & Design",
                    Email = "flower.blossom@eventhub.vn",
                    PhoneNumber = "0977889900",
                    AvatarUrl = "https://images.unsplash.com/photo-1561181286-d3fee7d55364?w=150",
                    UserRole = "Provider",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-2),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("22222222-2222-2222-2222-222222222228"),
                    FullName = "ProStage Event & Led Wall",
                    Email = "stage.pro@eventhub.vn",
                    PhoneNumber = "0966554433",
                    AvatarUrl = "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=150",
                    UserRole = "Provider",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-1),
                    UpdatedAt = DateTime.UtcNow
                },

                // ==========================================
                // 3. CUSTOMERS
                // ==========================================
                new ApplicationUser
                {
                    Id = DemoCustomerId,
                    FullName = "Khách hàng Demo",
                    Email = "customer@eventhub.vn",
                    PhoneNumber = "0901234567",
                    AvatarUrl = "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-4),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111112"),
                    FullName = "Nguyễn Văn An",
                    Email = "nguyen.van.an@gmail.com",
                    PhoneNumber = "0913579246",
                    AvatarUrl = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-45),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111113"),
                    FullName = "Trần Thị Mai",
                    Email = "tran.thi.mai@gmail.com",
                    PhoneNumber = "0924681357",
                    AvatarUrl = "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-40),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111114"),
                    FullName = "Lê Hoàng Nam",
                    Email = "le.hoang.nam@gmail.com",
                    PhoneNumber = "0936912151",
                    AvatarUrl = "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-35),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111115"),
                    FullName = "Phạm Quỳnh Nga",
                    Email = "pham.quynh.nga@gmail.com",
                    PhoneNumber = "0948123789",
                    AvatarUrl = "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-30),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111116"),
                    FullName = "Hoàng Đức Thắng",
                    Email = "hoang.duc.thang@gmail.com",
                    PhoneNumber = "0961234890",
                    AvatarUrl = "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-25),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111117"),
                    FullName = "Vũ Thu Trang",
                    Email = "vu.thu.trang@gmail.com",
                    PhoneNumber = "0973456123",
                    AvatarUrl = "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-20),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111118"),
                    FullName = "Đặng Tuấn Kiệt",
                    Email = "dang.tuan.kiet@gmail.com",
                    PhoneNumber = "0984567234",
                    AvatarUrl = "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-15),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111119"),
                    FullName = "Bùi Mỹ Linh",
                    Email = "bui.my.linh@gmail.com",
                    PhoneNumber = "0915678345",
                    AvatarUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-10),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111120"),
                    FullName = "Đỗ Gia Huy",
                    Email = "do.gia.huy@gmail.com",
                    PhoneNumber = "0926789456",
                    AvatarUrl = "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-7),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111121"),
                    FullName = "Ngô Phương Thảo",
                    Email = "ngo.phuong.thao@gmail.com",
                    PhoneNumber = "0937890567",
                    AvatarUrl = "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-3),
                    UpdatedAt = DateTime.UtcNow
                },
                new ApplicationUser
                {
                    Id = Guid.Parse("11111111-1111-1111-1111-111111111122"),
                    FullName = "Công ty CP FPT Software (Ban Sự kiện)",
                    Email = "fpt.software@eventhub.vn",
                    PhoneNumber = "02473007300",
                    AvatarUrl = "https://images.unsplash.com/photo-1577962917302-cd874c4e31d2?w=150",
                    UserRole = "Customer",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-1),
                    UpdatedAt = DateTime.UtcNow
                }
            };

            db.Users.AddRange(users);
            db.SaveChanges();
            logger.LogInformation("Successfully seeded {Count} users into Users table.", users.Count);
        }

        public static void SeedBookings(EventHubDbContext db, ILogger logger)
        {
            if (db.Bookings.Any())
            {
                logger.LogInformation("Bookings table already contains data, skipping seed.");
                return;
            }

            var bookings = new List<Booking>
            {
                new Booking
                {
                    Id = Guid.NewGuid(),
                    BookingCode = "EH-20261016-001",
                    CustomerId = DemoCustomerId,
                    ProviderId = DemoProviderId,
                    ServiceId = Guid.NewGuid(),
                    PackageNameSnapshot = "Gói Trang Trí Rustic Tiêu Chuẩn",
                    PackagePriceSnapshot = 15000000m,
                    TotalAmount = 15000000m,
                    EventDate = DateTime.Today.AddDays(4),
                    EventAddress = "123 Hoàng Mai, Hà Nội",
                    City = "Hà Nội",
                    GuestCount = 120,
                    SpecialRequirements = "Bổ sung 2 trụ hoa tươi ở lối đi",
                    Status = "Accepted",
                    CreatedAt = DateTime.UtcNow.AddHours(-4),
                    StatusUpdatedAt = DateTime.UtcNow.AddHours(-4)
                },
                new Booking
                {
                    Id = Guid.NewGuid(),
                    BookingCode = "EH-20261010-004",
                    CustomerId = DemoCustomerId,
                    ProviderId = Guid.Parse("22222222-2222-2222-2222-222222222223"), // Glow Media
                    ServiceId = Guid.NewGuid(),
                    PackageNameSnapshot = "Gói Phóng Sự HD",
                    PackagePriceSnapshot = 8500000m,
                    TotalAmount = 8500000m,
                    EventDate = DateTime.Today.AddDays(2),
                    EventAddress = "Khách sạn JW Marriott, Hà Nội",
                    City = "Hà Nội",
                    GuestCount = 80,
                    SpecialRequirements = "Cần quay 4K và giao clip highlight 60 giây",
                    Status = "Accepted",
                    CreatedAt = DateTime.UtcNow.AddDays(-2),
                    StatusUpdatedAt = DateTime.UtcNow.AddDays(-2)
                },
                new Booking
                {
                    Id = Guid.NewGuid(),
                    BookingCode = "EH-20261012-008",
                    CustomerId = Guid.Parse("11111111-1111-1111-1111-111111111112"), // Nguyễn Văn An
                    ProviderId = Guid.Parse("22222222-2222-2222-2222-222222222224"), // Vibe Sound
                    ServiceId = Guid.NewGuid(),
                    PackageNameSnapshot = "Gói Âm Thanh Ánh Sáng Hội Trường 200 Khách",
                    PackagePriceSnapshot = 6000000m,
                    TotalAmount = 6000000m,
                    EventDate = DateTime.Today.AddDays(3),
                    EventAddress = "Trung tâm Hội nghị Quốc Gia, Hà Nội",
                    City = "Hà Nội",
                    GuestCount = 200,
                    SpecialRequirements = "Cần 4 mic không dây và 2 loa sub",
                    Status = "Accepted",
                    CreatedAt = DateTime.UtcNow.AddDays(-3),
                    StatusUpdatedAt = DateTime.UtcNow.AddDays(-3)
                }
            };

            db.Bookings.AddRange(bookings);
            db.SaveChanges();
            logger.LogInformation("Successfully seeded {Count} bookings into Bookings table.", bookings.Count);
        }
    }
}
