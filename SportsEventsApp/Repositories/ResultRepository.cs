using Npgsql;
using System.Threading.Tasks;
using SportsEventsApp.Models;

namespace SportsEventsApp.Repositories
{
    public class ResultRepository : IResultRepository
    {
        private readonly DbContext _context;

        public ResultRepository(DbContext context)
        {
            _context = context;
        }

        public async Task AddResultAsync(Result result)
        {
            var conn = await _context.GetOpenConnectionAsync();

            using var cmd = new NpgsqlCommand("CALL sp_add_result(@p_athlete_id, @p_match_id, @p_points, @p_position)", conn);
            cmd.Parameters.AddWithValue("p_athlete_id", result.AthleteId);
            cmd.Parameters.AddWithValue("p_match_id", result.MatchId);
            cmd.Parameters.AddWithValue("p_points", result.Points);
            cmd.Parameters.AddWithValue("p_position", result.Position);

            await cmd.ExecuteNonQueryAsync();
        }
    }
}