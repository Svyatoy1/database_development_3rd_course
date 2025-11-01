namespace SportsEventsApp.Models
{
    public class Result
    {
        public int ResultId { get; set; }
        public int AthleteId { get; set; }
        public int MatchId { get; set; }
        public int Points { get; set; }
        public int Position { get; set; }
    }
}