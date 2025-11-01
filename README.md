# database_development_3rd_course
Repository for database development

**SportsEventsApp** is a C# (.NET 8) application that connects to a PostgreSQL database using stored procedures, views, and the Repository + Unit of Work patterns.  
It manages athletes, sports events, and results — all DB operations go through stored procedures.

---

## How to Run the Project

### Requirements
- PostgreSQL 15+ and **pgAdmin 4**
- **.NET 8 SDK**
- **Visual Studio 2022**
- **Git**

---

### Database Setup
1. Open **pgAdmin** and create a new database:
   ```
   SportsEventsDB
   ```
2. Open the **Query Tool** and execute the following SQL scripts from the `/SQL` folder in this order:
   ```sql
   \i 'SQL/SportsEventsDB.sql'       -- full database backup (tables + data)
   \i 'SQL/create_procedures.sql'    -- all CREATE PROCEDURE scripts
   \i 'SQL/create_views.sql'         -- all CREATE VIEW scripts
   ```
3. After execution, verify that:
   - Tables: `athlete`, `event`, `result`
   - Procedures: `sp_add_athlete`, `sp_add_event`, `sp_add_result`
   - Views: `v_athletes`, `v_events`, `v_results`

---

### Application Setup
1. Open the project in **Visual Studio**:
   ```
   File to Open to Project/Solution to SportsEventsApp.sln
   ```
2. Update the connection string in `DbContext.cs`:
   ```csharp
   _connectionString = "Host=localhost;Port=5432;Username=postgres;Password=12345678;Database=SportsEventsDB";
   ```
3. Build the project:
   ```
   Ctrl + Shift + B
   ```
4. Run the app:
   ```
   F5  or  Run to Start Debugging
   ```

---

### When Running
When launched, the app:
- Connects to PostgreSQL via **Npgsql**
- Adds example entities (Athlete, Event, Result) using stored procedures
- Outputs:
  ```
  Connected successfully.
  Inserting new athlete...
  Updating athlete...
  All entities added successfully!
  ```

---

### Project Structure
```
SportsEventsApp/
│
├── Models/
│   ├── Athlete.cs
│   ├── Event.cs
│   └── Result.cs
│
├── Repositories/
│   ├── AthleteRepository.cs
│   ├── EventRepository.cs
│   ├── ResultRepository.cs
│   ├── UnitOfWork.cs
│   ├── IAthleteRepository.cs
│   ├── IEventRepository.cs
│   └── IResultRepository.cs
│
├── SQL/
│   ├── SportsEventsDB.sql         # full database backup
│   ├── create_procedures.sql      # stored procedures
│   └── create_views.sql           # views
│
├── DbContext.cs
├── Program.cs
└── README.md
```

---

### 🧠 Technologies Used
- **C# / .NET 8**
- **PostgreSQL + pgAdmin 4**
- **Npgsql** (PostgreSQL ADO.NET Driver)
- **Repository + Unit of Work pattern**
- **Stored Procedures**
- **Views**
