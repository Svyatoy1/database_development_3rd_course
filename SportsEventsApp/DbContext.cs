using Npgsql;
using System;
using System.Threading.Tasks;

namespace SportsEventsApp
{
    public class DbContext : IDisposable
    {
        private readonly string _connectionString;
        private NpgsqlConnection _connection;

        public DbContext(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<NpgsqlConnection> GetOpenConnectionAsync()
        {
            if (_connection == null)
                _connection = new NpgsqlConnection(_connectionString);

            if (_connection.State != System.Data.ConnectionState.Open)
                await _connection.OpenAsync();

            return _connection;
        }

        public void Dispose()
        {
            _connection?.Dispose();
        }
    }
}