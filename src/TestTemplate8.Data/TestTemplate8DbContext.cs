using MassTransit;
using Microsoft.EntityFrameworkCore;
using TestTemplate8.Core.Entities;

namespace TestTemplate8.Data
{
    public class TestTemplate8DbContext : DbContext
    {
        public TestTemplate8DbContext(DbContextOptions options)
            : base(options)
        {
        }

        public DbSet<Foo> Foos { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.AddInboxStateEntity();
            modelBuilder.AddOutboxMessageEntity();
            modelBuilder.AddOutboxStateEntity();
        }
    }
}
