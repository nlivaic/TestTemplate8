using System.Threading.Tasks;

namespace TestTemplate8.Common.Interfaces
{
    public interface IUnitOfWork
    {
        Task<int> SaveAsync();
    }
}