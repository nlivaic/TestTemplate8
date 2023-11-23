using System.Collections.Generic;
using TestTemplate8.Core.Entities;
using TestTemplate8.Data;

namespace TestTemplate8.Api.Tests.Helpers
{
    public static class Seeder
    {
        public static void Seed(this TestTemplate8DbContext ctx)
        {
            ctx.Foos.AddRange(
                new List<Foo>
                {
                    new ("Text 1"),
                    new ("Text 2"),
                    new ("Text 3")
                });
            ctx.SaveChanges();
        }
    }
}
