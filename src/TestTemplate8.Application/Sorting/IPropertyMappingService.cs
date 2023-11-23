using System.Collections.Generic;
using TestTemplate8.Application.Sorting.Models;

namespace TestTemplate8.Application.Sorting
{
    public interface IPropertyMappingService
    {
        IEnumerable<SortCriteria> Resolve(BaseSortable sortableSource, BaseSortable sortableTarget);
    }
}
