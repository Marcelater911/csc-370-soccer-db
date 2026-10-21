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
