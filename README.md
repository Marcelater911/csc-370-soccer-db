# Soccer-db
Contributors: Abhishek, Marcelo, Kevin and Jawin.

## How to Run

### Requirements
- MySQL 8.0.18 or newer (needed for `EXPLAIN ANALYZE`)
- MySQL Workbench, or any SQL client that supports `LOAD DATA LOCAL INFILE`
- A local clone of this repository (the CSV files in `data/` are needed)

### 1. Enable loading local files (if useing my SQL)
The seed script loads data from CSV files, which MySQL blocks by default.
- **Server:** run `SET GLOBAL local_infile = 1;`
- **Workbench:** go to Database → Manage Connections → your connection → Advanced, add `OPT_LOCAL_INFILE=1` in the "Others" box, then reconnect.

### 2. Set the CSV paths in `seed.sql`
`seed.sql` uses placeholder paths (`'absolute path to stadiums.csv'`). Replace them with the location of the `data/` folder on your computer:
1. Find & Replace `absolute path to ` with the full path to your `data/` folder, ending in `/`. Use forward slashes `/`, even on Windows.
   - Mac example: `/Users/yourname/csc-370-soccer-db/data/`
   - Windows example: `C:/Users/yourname/csc-370-soccer-db/data/`
2. `premier_league_2024.csv` is in a different folder. Fix that one line by hand so it points to `data/teams/seasons/2024/premier_league_2024.csv`.

Do not commit these path changes; they only work on your computer.

### 3. Run the files in order
| Order | File | What it does |
|---|---|---|
| 1 | `sql/schema.sql` | Creates the database and all tables (drops any existing copy first) |
| 2 | `sql/seed.sql` | Loads the data from the CSV files |
| 3 | `sql/views.sql` | Creates the views (`v_standings`, `v_player_ages`, `v_match_results`) |
| 4 | `sql/queries.sql` | Runs the example queries and the `EXPLAIN ANALYZE` index comparison |

### 4. Check the data loaded
The end of `seed.sql` prints row counts. You should see **589** people, **562** players and **574** player season stats. If PlayerSeasonStats shows 0, the `premier_league_2024.csv` path is wrong (see step 2).

### Notes
- The `Scores` table has no data yet, so `v_match_results` shows no winners.
- `queries.sql` creates an index (`idx_standings_wins`). Running it a second time without re-running `schema.sql` gives a "duplicate key name" error.


## Idea
This project is built to capture the soccer league management system of Europe's top 5 soccer leagues. The Idea is to replicate the backend and database architecture of a digital soccer media tracking platform which allows users to quickly find information about the latest games, upcoming fixtures, updated league standings, match statistics, and get more information about core entities (player, coaches, teams, leagues) of the game.

## Features

Finished:
- Database schema (DDL) with all core tables, foreign keys, composite primary keys and CHECK constraints ([schema.sql](sql/schema.sql))
- Real data from the API loaded for all tables except Scores ([seed.sql](sql/seed.sql))
- Views that calculate derived values instead of storing them: points, matches played and league position (window function), player age, match winner ([views.sql](sql/views.sql))
- Queries covering subqueries, aggregation, outer joins and index performance with EXPLAIN ANALYZE ([queries.sql](sql/queries.sql))

To be Implemented:

- Live updates for upcoming matches/fixtures
- Displaying player performance metrics like top scorers, assists, and penalties.

## Design Implemenation
We used draw.io to build the Entity Relationship Diagram (ERD), covering all current tables, their relations, cardinalities, and keys. We used the standard ERD entity table and arrow notation instead of Chen-style notation, since it took up less space and let us fit attribute details directly inside each table box. After that we impolemented the entire ERD using SQL DDL commands inside a [schema.sql](sql/schema.sql) file.

## Example Table
The `Fixtures` table holds `match_id` (primary key), `home_team_id`, `away_team_id`, `season_id`, `stadium_id`, `match_referee`, and `utc_kickoff`. It is related to the `Teams`, `Seasons` and `Stadiums` tables through the above mentioned fields referencing the primary keys in these tables. Each match also links to one row in `Scores` and two rows (home and away) in `TeamMatchStatistics`. The winner is not stored; it is calculated from the score in the `v_match_results` view.
```
CREATE TABLE Fixtures (
    match_id        int PRIMARY KEY,
    home_team_id    int NOT NULL,
    away_team_id    int NOT NULL,
    season_id       int NOT NULL,
    stadium_id      int,
    match_referee   varchar(40),
    utc_kickoff     datetime,
    CHECK (home_team_id <> away_team_id),
    FOREIGN KEY (home_team_id) REFERENCES Teams (team_id),
    FOREIGN KEY (away_team_id) REFERENCES Teams (team_id),
    FOREIGN KEY (season_id) REFERENCES Seasons (season_id),
    FOREIGN KEY (stadium_id) REFERENCES Stadiums (stadium_id),
    CONSTRAINT uk_fixture UNIQUE (season_id, home_team_id, away_team_id)
);
```

## Sprint goals 1
- Defined a set of requiremts, entities and relations for the inital project database ✅
- Create an Entity Relationship Diagram (ERD) for the defined entities and relations ✅
- Implemented the ERD in SQL DDL code ✅
- Finalized all relationships using foreign keys between every entity. ✅
- Identified every instance of a BCNF Violation and Normalized the database ✅


## Next Sprint planning (previous sprint)
- Finish any previously missed sprint goals.
- Initialize the backend and implement the database using a framework. (preferably PostgreSQL)
- Populate tables with real data.
- Run queries and test performance.
- Check for BCNF violations and normalize the database.
- Simulate matches to see real-time updates.


### Current sprint 2
- Cleaned up Fixtures (removed stored winner, datetime kickoff, no duplicate fixtures) and added Scores CHECKs ✅
- Restructured match statistics into one row per team per match (TeamMatchStatistics) ✅
- Composite primary keys to enforce uniqueness by design (TeamMatchStatistics, PlayerSeasonStats, Standings) ✅
- Views and window functions to replace stored redundancy ✅
- Populated the remaining tables with real data ✅ (except Scores)
- Queries using GROUP BY/HAVING, subqueries, and a subquery converted to an outer join ✅
- Secondary index tested with EXPLAIN ANALYZE ✅

## Next Sprint planning
- Load match scores.
- add queries that use veiws
- acid transactions
- badic security
- analysisng querey algoritms
- add data dump

## References
- Took inspiration from a similar project implementing a [Football League Management System](https://github.com/kaimg/Sports-League-Management-System)
- Football data European Top 5 Leagues from [Kaggle](https://www.kaggle.com/datasets/kamrangayibov/football-data-european-top-5-leagues)
