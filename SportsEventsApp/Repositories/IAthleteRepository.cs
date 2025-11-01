using System.Threading.Tasks;
using SportsEventsApp.Models;

namespace SportsEventsApp.Repositories
{
    public interface IAthleteRepository
    {
        Task AddAthleteAsync(Athlete athlete);
    }
}