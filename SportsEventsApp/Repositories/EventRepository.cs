using Npgsql;
using System.Threading.Tasks;
using SportsEventsApp.Models;

namespace SportsEventsApp.Repositories
{
    public class EventRepository : IEventRepository
    {
        private readonly DbContext _context;

        public EventRepository(DbContext context)
        {
            _context = context;
        }

        public async Task AddEventAsync(Event evt)
        {
            var conn = await _context.GetOpenConnectionAsync();

            using var cmd = new NpgsqlCommand(
                "CALL sp_add_event(@p_name, @p_start_date, @p_location_id)", conn
            );

            cmd.Parameters.AddWithValue("@p_name", NpgsqlTypes.NpgsqlDbType.Varchar, evt.Name);
            cmd.Parameters.AddWithValue("@p_start_date", NpgsqlTypes.NpgsqlDbType.Date, evt.StartDate);
            cmd.Parameters.AddWithValue("@p_location_id", NpgsqlTypes.NpgsqlDbType.Integer, evt.LocationId);

            await cmd.ExecuteNonQueryAsync();
        }
    }
}