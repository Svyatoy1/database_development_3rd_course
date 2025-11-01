using System;
using System.Threading.Tasks;
using SportsEventsApp.Models;
using SportsEventsApp.Repositories;

namespace SportsEventsApp
{
    class Program
    {
        static async Task Main()
        {
            var connString = "Host=localhost;Username=postgres;Password=12345678;Database=SportsEventsDB";

            using var dbContext = new DbContext(connString);
            var unitOfWork = new UnitOfWork(dbContext);

            Console.WriteLine("Connected successfully.");

            //  Додаємо спортсмена
            var athlete = new Athlete
            {
                FirstName = "John",
                LastName = "Doe",
                BirthDate = new DateTime(1998, 5, 12),
                Gender = "M"
            };
            await unitOfWork.Athletes.AddAthleteAsync(athlete);

            //  Додаємо подію
            var evt = new Event
            {
                Name = "Summer Cup",
                StartDate = new DateTime(2025, 6, 1),
                LocationId = 2
            };
            await unitOfWork.Events.AddEventAsync(evt);

            //  Додаємо результат
            var result = new Result
            {
                AthleteId = 1,
                MatchId = 1,
                Points = 95,
                Position = 1
            };
            await unitOfWork.Results.AddResultAsync(result);

            Console.WriteLine("All entities added successfully!");
        }
    }
}