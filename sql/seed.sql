-- Seed data script
USE soccer_project;

-- Countries (country_id is assigned by AUTO_INCREMENT)
INSERT INTO Countries (name, flag_url) VALUES
('England', 'https://media.api-sports.io/flags/gb-eng.svg'),
('Spain', 'https://media.api-sports.io/flags/es.svg'),
('Germany', 'https://media.api-sports.io/flags/de.svg'),
('Italy', 'https://media.api-sports.io/flags/it.svg'),
('France', 'https://media.api-sports.io/flags/fr.svg');

-- Leagues: league_id is assigned by AUTO_INCREMENT; country_id is looked up from the Countries table by country name
INSERT INTO Leagues (name, country_id) VALUES
('Premier League',   (SELECT country_id FROM Countries WHERE name = 'England')),
('Championship',     (SELECT country_id FROM Countries WHERE name = 'England')),
('La Liga',          (SELECT country_id FROM Countries WHERE name = 'Spain')),
('Segunda División', (SELECT country_id FROM Countries WHERE name = 'Spain')),
('Bundesliga',       (SELECT country_id FROM Countries WHERE name = 'Germany')),
('2. Bundesliga',    (SELECT country_id FROM Countries WHERE name = 'Germany')),
('Serie A',          (SELECT country_id FROM Countries WHERE name = 'Italy')),
('Serie B',          (SELECT country_id FROM Countries WHERE name = 'Italy')),
('Ligue 1',          (SELECT country_id FROM Countries WHERE name = 'France')),
('Ligue 2',          (SELECT country_id FROM Countries WHERE name = 'France'));

-- Stadiums: stadium_id is assigned by AUTO_INCREMENT; rows come from data/stadiums.csv.
-- The path is relative to the directory where mysql is started from, and LOCAL requires local_infile to be enabled.
LOAD DATA LOCAL INFILE 'absolute path to stadiums.csv'
INTO TABLE Stadiums
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(name, city, @capacity)
SET capacity = NULLIF(@capacity, '');

-- Teams: team_id is assigned by AUTO_INCREMENT; rows come from data/teams.csv.
-- league_id and stadium_id are looked up by name.
LOAD DATA LOCAL INFILE 'absolute path to teams.csv'
INTO TABLE Teams
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(name, @league_name, @venue_name, @year_established)
SET league_id        = (SELECT league_id FROM Leagues WHERE name = NULLIF(@league_name, '')),
    stadium_id       = (SELECT stadium_id FROM Stadiums WHERE name = @venue_name),
    year_established = NULLIF(@year_established, '');

-- Seasons: season_id is assigned by AUTO_INCREMENT; rows come from data/seasons.csv,
-- currently only 2023/24 and 2024/25. league_id is looked up by league and country name.
LOAD DATA LOCAL INFILE 'absolute path to seasons.csv'
INTO TABLE Seasons
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@league_name, @country_name, start_year, end_year)
SET league_id = (SELECT league_id FROM Leagues WHERE name = @league_name);

-- Standings: standing_id is assigned by AUTO_INCREMENT; rows come from data/standings.csv.
-- season_id is looked up by league name and start year, team_id by team name. Promotion and relegation are all 0 (false) for now.
LOAD DATA LOCAL INFILE 'absolute path to standings.csv'
INTO TABLE Standings
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@league_name, @start_year, @team_name, position, matches_played, wins, losses, draws, goal_difference, promotion, relegation)
SET season_id = (
        SELECT s.season_id
        FROM Seasons s
        JOIN Leagues l ON l.league_id = s.league_id
        WHERE l.name = @league_name AND s.start_year = @start_year
    ),
    team_id = (SELECT team_id FROM Teams WHERE name = @team_name);

-- Fixtures: regular season 2024/25 matches of all 10 leagues, from data/fixtures.csv.
-- match_id is the API fixture id (TeamMatchStatistics refers to it), season_id is looked up by league name
-- and start year, the team and stadium ids by name. Venues not in Stadiums get a NULL stadium_id.
LOAD DATA LOCAL INFILE 'absolute path to fixtures.csv'
INTO TABLE Fixtures
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(match_id, @league_name, @start_year, @home_team_name, @away_team_name, @venue_name, @referee, utc_kickoff)
SET season_id = (
        SELECT s.season_id
        FROM Seasons s
        JOIN Leagues l ON l.league_id = s.league_id
        WHERE l.name = @league_name AND s.start_year = @start_year
    ),
    home_team_id  = (SELECT team_id FROM Teams WHERE name = @home_team_name),
    away_team_id  = (SELECT team_id FROM Teams WHERE name = @away_team_name),
    stadium_id    = (SELECT stadium_id FROM Stadiums WHERE name = @venue_name),
    match_referee = NULLIF(@referee, '');

-- TeamMatchStatistics: two rows (home and away) per Premier League match, from data/team_match_statistics.csv.
-- match_id is the API fixture id, so the Fixtures table must already hold these matches (foreign key),
-- otherwise LOAD DATA LOCAL skips the rows with only a warning. Only 50 matches for Premier League 2024-25 are included
-- due to free-tier API rate limits, so not all 380 matches of the season are present.
LOAD DATA LOCAL INFILE 'absolute path to team_match_statistics.csv'
INTO TABLE TeamMatchStatistics
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(match_id, side, @shots_on_target, @shots_off_target, @total_shots, @corners, @offsides, @fouls,
 @total_passes, @yellow_cards, @red_cards, @passes_accurate, @ball_possession)
SET shots_on_target  = NULLIF(@shots_on_target, ''),
    shots_off_target = NULLIF(@shots_off_target, ''),
    total_shots      = NULLIF(@total_shots, ''),
    corners          = NULLIF(@corners, ''),
    offsides         = NULLIF(@offsides, ''),
    fouls            = NULLIF(@fouls, ''),
    total_passes     = NULLIF(@total_passes, ''),
    yellow_cards     = NULLIF(@yellow_cards, ''),
    red_cards        = NULLIF(@red_cards, ''),
    passes_accurate  = NULLIF(@passes_accurate, ''),
    ball_possession  = NULLIF(@ball_possession, '');

-- ---------------------------------------------------------------------------------------------
-- Person, Players and PlayerSeasonStats (Premier League 2024/25 only)
-- The CSVs use the API's own ids for people and teams. They are first loaded into staging tables,
-- which map them to our ids, and the staging tables are dropped at the end.
-- ---------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS StagingTeamIds, StagingPerson, StagingNationality, StagingPlayers, StagingPlayerSeasonStats;

-- API team id -> team name, from the Premier League teams file the player data was fetched with
CREATE TABLE StagingTeamIds (
    api_team_id int PRIMARY KEY,
    team_name   varchar(50) NOT NULL
);
LOAD DATA LOCAL INFILE 'absolute path to premier_league_2024.csv'
INTO TABLE StagingTeamIds
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(api_team_id, team_name, @code, @founded, @venue_id, @venue_name, @venue_address, @venue_city, @venue_capacity);

-- new_person_id is the new AUTO_INCREMENT id that Person gets; api_person_id is the id from the CSVs
CREATE TABLE StagingPerson (
    new_person_id int AUTO_INCREMENT PRIMARY KEY,
    api_person_id int NOT NULL UNIQUE,
    api_team_id   int,
    first_name    varchar(50) NOT NULL,
    last_name     varchar(50) NOT NULL,
    date_of_birth date,
    is_coach      boolean
);
-- \N in the CSVs is read as NULL; the country_id column is skipped (nationality comes from person_country_lookup.csv)
LOAD DATA LOCAL INFILE 'absolute path to Person.csv'
INTO TABLE StagingPerson
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(api_person_id, api_team_id, first_name, last_name, date_of_birth, @country_id, is_coach);

CREATE TABLE StagingNationality (
    api_person_id int PRIMARY KEY,
    country_name  varchar(50)
);
LOAD DATA LOCAL INFILE 'absolute path to person_country_lookup.csv'
INTO TABLE StagingNationality
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(api_person_id, country_name);

CREATE TABLE StagingPlayers (
    api_person_id int PRIMARY KEY,
    position      varchar(50)
);
-- jersey_num is skipped because the Players table has no jersey number column
LOAD DATA LOCAL INFILE 'absolute path to Players.csv'
INTO TABLE StagingPlayers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(api_person_id, position, @jersey_num);

CREATE TABLE StagingPlayerSeasonStats (
    api_person_id int,
    api_team_id   int,
    goals         int,
    assists       int,
    penalties     int
);
-- The CSV's season_id column is skipped; the season is looked up below as Premier League 2024/25
LOAD DATA LOCAL INFILE 'absolute path to PlayerSeasonStats.csv'
INTO TABLE StagingPlayerSeasonStats
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(api_person_id, @season_id, api_team_id, goals, assists, penalties);

-- Person: team_id is found through API team id -> team name -> Teams, nationality through the lookup file
INSERT INTO Person (person_id, team_id, first_name, last_name, date_of_birth, nationality, is_coach)
SELECT sp.new_person_id, t.team_id, sp.first_name, sp.last_name, sp.date_of_birth, n.country_name, sp.is_coach
FROM StagingPerson sp
LEFT JOIN StagingTeamIds st ON st.api_team_id = sp.api_team_id
LEFT JOIN Teams t ON t.name = st.team_name
LEFT JOIN StagingNationality n ON n.api_person_id = sp.api_person_id
ORDER BY sp.new_person_id;

-- Players: the API person id is swapped for the new Person id
INSERT INTO Players (person_id, position)
SELECT sp.new_person_id, p.position
FROM StagingPlayers p
JOIN StagingPerson sp ON sp.api_person_id = p.api_person_id;

-- PlayerSeasonStats: one row per player per team (players who moved mid-season have two rows)
INSERT INTO PlayerSeasonStats (player_id, season_id, team_id, goals, assists, penalties)
SELECT sp.new_person_id, s.season_id, t.team_id, ps.goals, ps.assists, ps.penalties
FROM StagingPlayerSeasonStats ps
JOIN StagingPerson sp ON sp.api_person_id = ps.api_person_id
JOIN StagingTeamIds st ON st.api_team_id = ps.api_team_id
JOIN Teams t ON t.name = st.team_name
JOIN Seasons s ON s.start_year = 2024
JOIN Leagues l ON l.league_id = s.league_id AND l.name = 'Premier League';

DROP TABLE StagingTeamIds, StagingPerson, StagingNationality, StagingPlayers, StagingPlayerSeasonStats;

-- Expected: 589 people (27 coaches), 562 players, 574 player season stats
SELECT COUNT(*) FROM Person;
SELECT COUNT(*) FROM Players;
SELECT COUNT(*) FROM PlayerSeasonStats;

SELECT Count(*) FROM `Person` WHERE is_coach = 1;