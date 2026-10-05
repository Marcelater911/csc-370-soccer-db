# Soccer-db
Contributors: Abhishek, Marcelo, Kevin and Jawin.

## Idea
This project is built to capture the soccer league management system of Europe's top 5 soccer leagues. The Idea is to replicate the backend and database architecture of a digital soccer media tracking platform which allows users to quickly find information about the latest games, upcoming fixtures, updated league standings, match statistics, and get more information about core entities (player, coaches, teams, leagues) of the game.

## Features

Finished:
- Database schema (DDL) with all core tables set up and ready to inspect <br>

To be Implemented:
- Simulating matches and show live league standing updates
- Retrievingh historical match data (scores, statistics)
- Live updates for upcoming matches/fixtures
- Displaying player performance metrics like top scorers, assists, and penalties.

## Design Implemenation
We used draw.io to build the Entity Relationship Diagram (ERD), covering all current tables, their relations, cardinalities, and keys. We used the standard ERD entity table and arrow notation instead of Chen-style notation, since it took up less space and let us fit attribute details directly inside each table box. After that we impolemented the entire ERD using SQL DDL commands inside a [schema.sql](sql/schema.sql) file.

## Example Table
The `Matches` table holds `match_id` (primary key), `home_team_id`, `away_team_id`, `league_id`, `season_id`, `stadium_id`, `winner_id`, `match_referee_id`, and `utc_kickoff`. It is related to the `Teams`, `Leagues`, `Seasons`, `Stadiums` and `Referees` tables through the above mentioned feilds referencing the primary keys in these tables. Each match also links to one row in`Scores` and `MatchStatistics`.
```
CREATE TABLE Matches (
    match_id        int PRIMARY KEY,
    home_team_id    int,
    away_team_id    int,
    league_id       int,
    season_id       int,
    stadium_id      int,
    winner_id       int,
    match_referee_id int,
    utc_kickoff     date
);
```

## Sprint goals
- Defined a set of requiremts, entities and relations for the inital project database ✅
- Create an Entity Relationship Diagram (ERD) for the defined entities and relations ✅
- Implemented the ERD in SQL DDL code ✅
- Finalized all relationships using foreign keys between every entity. ❌
- Identified every instance of a BCNF Violation and Normalized the database ❌

Justification for missed sprint goals<br>

- Many changes occured in terms of requirements, data representation and data types while establishing relations in the ERD diagram leading to last minute schema changes. Which is why instead of rushing the critical design phase, we left some of relations to be identified and completed for the next sprint.
- One such Violation is the ```team_id``` -> ``league_id`` relation, since every table belongs to exactly one league which is enforced in Teams table it is redundant for any other table to reference the ```league_id``` by itself. If the table is referencing a team, the league name can then be obtained by the team itself.


## Next Sprint planning
- Finish any previously missed sprint goals.
- Initialize the backend and implement the database using a framework. (preferably PostgreSQL)
- Populate tables with real data.
- Run queries and test performance.
- Check for BCNF violations and normalize the database.
- Simulate matches to see real-time updates.

## References
- Took inspiration from a similar project implementing a [Football League Management System](https://github.com/kaimg/Sports-League-Management-System)
- Football data European Top 5 Leagues from [Kaggle](https://www.kaggle.com/datasets/kamrangayibov/football-data-european-top-5-leagues)
