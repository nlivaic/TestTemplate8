using TestTemplate8.Core.Entities;
using TestTemplate8.Core.Interfaces;

namespace TestTemplate8.Data.Repositories
{
    public class FooRepository : Repository<Foo>, IFooRepository
    {
        public FooRepository(TestTemplate8DbContext context)
            : base(context)
        {
        }
    }
}
