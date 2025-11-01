using System.Threading.Tasks;
using SportsEventsApp.Models;

namespace SportsEventsApp.Repositories
{
    public interface IResultRepository
    {
        Task AddResultAsync(Result result);
    }
}