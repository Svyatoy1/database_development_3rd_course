using System.Threading.Tasks;
using SportsEventsApp.Models;

namespace SportsEventsApp.Repositories
{
    public interface IEventRepository
    {
        Task AddEventAsync(Event evt);
    }
}