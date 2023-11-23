using System.Threading.Tasks;
using TestTemplate8.Common.Interfaces;

namespace TestTemplate8.Data
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly TestTemplate8DbContext _dbContext;

        public UnitOfWork(TestTemplate8DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<int> SaveAsync()
        {
            if (_dbContext.ChangeTracker.HasChanges())
            {
                return await _dbContext.SaveChangesAsync();
            }
            return 0;
        }
    }
}