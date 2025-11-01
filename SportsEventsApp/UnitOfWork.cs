namespace SportsEventsApp.Repositories
{
    public class UnitOfWork
    {
        private readonly DbContext _context;

        public IAthleteRepository Athletes { get; }
        public IEventRepository Events { get; }
        public IResultRepository Results { get; }

        public UnitOfWork(DbContext context)
        {
            _context = context;
            Athletes = new AthleteRepository(context);
            Events = new EventRepository(context);
            Results = new ResultRepository(context);
        }
    }
}