using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using EventHub.API.Controllers;
using EventHub.Domain.Entities;
using EventHub.Infrastructure.Data;
using Xunit;

namespace EventHub.Tests
{
    public class BackendControllersTests
    {
        private EventHubDbContext CreateInMemoryDbContext()
        {
            var options = new DbContextOptionsBuilder<EventHubDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;

            return new EventHubDbContext(options);
        }

        [Fact]
        public async Task AuthController_Login_Fails_When_User_Is_Locked()
        {
            // Arrange
            using var context = CreateInMemoryDbContext();
            var logger = NullLogger<AuthController>.Instance;
            var controller = new AuthController(context, logger);

            var lockedUser = new ApplicationUser
            {
                Id = Guid.NewGuid(),
                FullName = "Locked Customer",
                Email = "locked@eventhub.vn",
                Password = "Password123!",
                IsActive = false,
                UserRole = "Customer"
            };
            context.Users.Add(lockedUser);
            await context.SaveChangesAsync();

            // Act
            var result = await controller.Login(new AuthController.LoginRequest
            {
                Email = "locked@eventhub.vn",
                Password = "Password123!"
            });

            // Assert
            var unauthorized = Assert.IsType<UnauthorizedObjectResult>(result);
            Assert.NotNull(unauthorized.Value);
        }

        [Fact]
        public async Task AuthController_Login_Succeeds_When_User_Is_Active()
        {
            // Arrange
            using var context = CreateInMemoryDbContext();
            var logger = NullLogger<AuthController>.Instance;
            var controller = new AuthController(context, logger);

            var activeUser = new ApplicationUser
            {
                Id = Guid.NewGuid(),
                FullName = "Active Customer",
                Email = "active@eventhub.vn",
                Password = "1234567",
                IsActive = true,
                UserRole = "Customer"
            };
            context.Users.Add(activeUser);
            await context.SaveChangesAsync();

            // Act
            var result = await controller.Login(new AuthController.LoginRequest
            {
                Email = "active@eventhub.vn",
                Password = "1234567"
            });

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.NotNull(okResult.Value);
        }

        [Fact]
        public async Task UsersController_ToggleUserStatus_Locks_And_Unlocks_User()
        {
            // Arrange
            using var context = CreateInMemoryDbContext();
            var logger = NullLogger<UsersController>.Instance;
            var controller = new UsersController(context, logger);

            var user = new ApplicationUser
            {
                Id = Guid.NewGuid(),
                FullName = "Test Provider",
                Email = "provider@eventhub.vn",
                Password = "1234567",
                IsActive = true,
                UserRole = "Provider"
            };
            context.Users.Add(user);
            await context.SaveChangesAsync();

            // Act 1: Toggle to lock
            var lockResult = await controller.ToggleUserStatus(user.Id);
            var lockOk = Assert.IsType<OkObjectResult>(lockResult);
            Assert.NotNull(lockOk.Value);

            var updatedUser = await context.Users.FindAsync(user.Id);
            Assert.NotNull(updatedUser);
            Assert.False(updatedUser.IsActive);

            // Act 2: Toggle to unlock
            var unlockResult = await controller.ToggleUserStatus(user.Id);
            var unlockOk = Assert.IsType<OkObjectResult>(unlockResult);
            Assert.NotNull(unlockOk.Value);

            var restoredUser = await context.Users.FindAsync(user.Id);
            Assert.NotNull(restoredUser);
            Assert.True(restoredUser.IsActive);
        }

        [Fact]
        public async Task BookingsController_ReviewBooking_Rejects_Invalid_Status_Or_Rating()
        {
            // Arrange
            using var context = CreateInMemoryDbContext();
            var controller = new BookingsController(context);

            var booking = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "EH-TEST-001",
                Status = "Confirmed", // Not completed yet
                TotalAmount = 5000000m
            };
            context.Bookings.Add(booking);
            await context.SaveChangesAsync();

            // Act 1: Rating invalid (< 1)
            var badRating = await controller.ReviewBooking(booking.Id, new ReviewBookingRequest
            {
                Rating = 0,
                ReviewComment = "Bad"
            });
            Assert.IsType<BadRequestObjectResult>(badRating);

            // Act 2: Status not completed
            var notCompleted = await controller.ReviewBooking(booking.Id, new ReviewBookingRequest
            {
                Rating = 5,
                ReviewComment = "Tuyệt vời"
            });
            Assert.IsType<BadRequestObjectResult>(notCompleted);
        }

        [Fact]
        public async Task BookingsController_ReviewBooking_Succeeds_When_Completed()
        {
            // Arrange
            using var context = CreateInMemoryDbContext();
            var controller = new BookingsController(context);

            var booking = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "EH-TEST-002",
                Status = "Completed",
                TotalAmount = 8000000m
            };
            context.Bookings.Add(booking);
            await context.SaveChangesAsync();

            // Act
            var result = await controller.ReviewBooking(booking.Id, new ReviewBookingRequest
            {
                Rating = 5,
                ReviewComment = "Dịch vụ trang trí tiệc cưới rất đẹp và chuyên nghiệp!"
            });

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.NotNull(okResult.Value);

            var updated = await context.Bookings.FindAsync(booking.Id);
            Assert.NotNull(updated);
            Assert.Equal(5, updated.Rating);
            Assert.Equal("Dịch vụ trang trí tiệc cưới rất đẹp và chuyên nghiệp!", updated.ReviewComment);
            Assert.NotNull(updated.ReviewedAt);
        }

        [Fact]
        public async Task ProviderBookingsController_StartBooking_Updates_To_InProgress()
        {
            // Arrange
            using var context = CreateInMemoryDbContext();
            var controller = new ProviderBookingsController(context);

            var booking = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "EH-TEST-003",
                Status = "Confirmed",
                TotalAmount = 12000000m
            };
            context.Bookings.Add(booking);
            await context.SaveChangesAsync();

            // Act
            var result = await controller.StartBooking(booking.Id);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.NotNull(okResult.Value);

            var updated = await context.Bookings.FindAsync(booking.Id);
            Assert.NotNull(updated);
            Assert.Equal("InProgress", updated.Status);
        }
    }
}
