namespace SportsEventsApp.Models
{
    public class Event
    {
        public int EventId { get; set; }
        public string Name { get; set; }
        public DateTime StartDate { get; set; }
        public int LocationId { get; set; }
    }
}