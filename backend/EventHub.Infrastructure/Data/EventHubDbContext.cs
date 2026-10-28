using Microsoft.EntityFrameworkCore;
using EventHub.Domain.Entities;

namespace EventHub.Infrastructure.Data
{
    public class EventHubDbContext : DbContext
    {
        public EventHubDbContext(DbContextOptions<EventHubDbContext> options) : base(options)
        {
        }

        public DbSet<Booking> Bookings => Set<Booking>();
        public DbSet<ApplicationUser> Users => Set<ApplicationUser>();
        public DbSet<Service> Services => Set<Service>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Booking>(b =>
            {
                b.HasKey(x => x.Id);
                b.Property(x => x.BookingCode).IsRequired().HasMaxLength(50);
                b.HasIndex(x => x.BookingCode).IsUnique();
                b.Property(x => x.PackageNameSnapshot).HasMaxLength(255);
                b.Property(x => x.PackagePriceSnapshot).HasPrecision(18, 2);
                b.Property(x => x.TotalAmount).HasPrecision(18, 2);
                b.Property(x => x.Status).HasMaxLength(50);
            });

            modelBuilder.Entity<ApplicationUser>(u =>
            {
                u.HasKey(x => x.Id);
                u.Property(x => x.Email).IsRequired().HasMaxLength(255);
                u.Property(x => x.FullName).IsRequired().HasMaxLength(255);
                u.Property(x => x.Password).IsRequired().HasMaxLength(255);
            });

            modelBuilder.Entity<Service>(s =>
            {
                s.HasKey(x => x.Id);
                s.Property(x => x.Title).IsRequired().HasMaxLength(255);
                s.Property(x => x.BasePrice).HasPrecision(18, 2);
                s.Property(x => x.RatingAverage).HasPrecision(3, 2);
            });
        }
    }
}
