using Npgsql;
using System.Threading.Tasks;
using SportsEventsApp.Models;

namespace SportsEventsApp.Repositories
{
    public class AthleteRepository : IAthleteRepository
    {
        private readonly DbContext _context;

        public AthleteRepository(DbContext context)
        {
            _context = context;
        }

        public async Task AddAthleteAsync(Athlete athlete)
        {
            var conn = await _context.GetOpenConnectionAsync();

            using var cmd = new NpgsqlCommand(
                "CALL sp_add_athlete(@p_first_name, @p_last_name, @p_birth_date, @p_gender)",
                conn
            );

            cmd.Parameters.AddWithValue("@p_first_name", NpgsqlTypes.NpgsqlDbType.Varchar, athlete.FirstName);
            cmd.Parameters.AddWithValue("@p_last_name", NpgsqlTypes.NpgsqlDbType.Varchar, athlete.LastName);
            cmd.Parameters.AddWithValue("@p_birth_date", NpgsqlTypes.NpgsqlDbType.Date, athlete.BirthDate);
            cmd.Parameters.AddWithValue("@p_gender", NpgsqlTypes.NpgsqlDbType.Varchar, athlete.Gender);

            await cmd.ExecuteNonQueryAsync();
        }
    }
}