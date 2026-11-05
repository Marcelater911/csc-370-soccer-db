DROP DATABASE IF EXISTS soccer_project;
CREATE DATABASE soccer_project;
USE soccer_project;

CREATE TABLE Countries (
    country_id int AUTO_INCREMENT PRIMARY KEY,
    name       varchar(40) NOT NULL UNIQUE,
    flag_url   varchar(100)
);

CREATE TABLE Leagues (
    league_id        int AUTO_INCREMENT PRIMARY KEY,
    name             varchar(40) NOT NULL,
    country_id       int NOT NULL,
    FOREIGN KEY (country_id) REFERENCES Countries (country_id),
    CONSTRAINT uk_league_name_country UNIQUE (name, country_id)
);

CREATE TABLE Stadiums (
    stadium_id int AUTO_INCREMENT PRIMARY KEY,
    name       varchar(60) NOT NULL UNIQUE,
    city       varchar(40),
    capacity   int
);

CREATE TABLE Teams (
    team_id          int AUTO_INCREMENT PRIMARY KEY,
    name             varchar(50) NOT NULL UNIQUE,
    league_id        int,
    stadium_id       int,
    year_established int,
    FOREIGN KEY (league_id) REFERENCES Leagues (league_id),
    FOREIGN KEY (stadium_id) REFERENCES Stadiums (stadium_id)
);

CREATE TABLE Person (
    person_id     int PRIMARY KEY,
    team_id       int,
    first_name    varchar(50) NOT NULL,
    last_name     varchar(50) NOT NULL,
    date_of_birth date,
    country_id    int,
    is_coach      boolean,
    FOREIGN KEY (team_id) REFERENCES Teams (team_id),
    FOREIGN KEY (country_id) REFERENCES Countries (country_id)
);

CREATE TABLE Players (
    person_id     int PRIMARY KEY,
    position      varchar(50),
    jersey_num    int,
    FOREIGN KEY (person_id) REFERENCES Person (person_id) ON DELETE CASCADE
);

CREATE TABLE Seasons (
    season_id        int AUTO_INCREMENT PRIMARY KEY,
    league_id        int NOT NULL,
    start_year       int NOT NULL,
    end_year         int NOT NULL,
    FOREIGN KEY (league_id) REFERENCES Leagues (league_id),
    CONSTRAINT uk_league_season UNIQUE (league_id, start_year)
);

CREATE TABLE Fixtures (
    match_id        int PRIMARY KEY,
    home_team_id    int not NULL,
    away_team_id    int not NULL,
    season_id       int,
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

CREATE TABLE Scores (
    match_id       int PRIMARY KEY,
    full_time_home int,
    full_time_away int,
    half_time_home int,
	half_time_away int,
    CHECK(full_time_home >= 0 and full_time_away >= 0 and half_time_home >= 0 and half_time_away >= 0),
	CHECK(half_time_away <= full_time_away),
	CHECK(half_time_home <= full_time_home),
    FOREIGN KEY (match_id) REFERENCES Fixtures (match_id)
);

CREATE TABLE TeamMatchStatistics (
    match_id             int,
    side				 varchar(4),
    total_shots			 int,
	shot_accuracy		 DECIMAL(5,2),
    corners				 int,
    offsides			 int,
    tackles				 int,
	total_passes		 int,
    possession			 DECIMAL(5,2),
    PRIMARY KEY (match_id, side),
    CHECK (side IN ('home', 'away')),
    CHECK (total_shots >=0 and corners >=0 and offsides >=0 and tackles >=0 and total_passes >=0),
    CHECK (shot_accuracy >= 0 and shot_accuracy <= 100 and possession >= 0 and possession <= 100),
    FOREIGN KEY (match_id) REFERENCES Fixtures (match_id)
);

CREATE TABLE Standings (
    standing_id     int AUTO_INCREMENT PRIMARY KEY,
    season_id       int,
    team_id         int,
    position        int,
    matches_played  int,
    wins            int,
    losses          int,
    draws           int,
    goal_difference int,
    promotion       boolean,
    relegation      boolean,
    FOREIGN KEY (season_id) REFERENCES Seasons (season_id),
    FOREIGN KEY (team_id) REFERENCES Teams (team_id),
    CONSTRAINT uk_season_team UNIQUE (season_id, team_id)
);

CREATE TABLE PlayerSeasonStats (
    scorer_id int PRIMARY KEY,
    player_id int,
    season_id int,
    team_id   int,
    goals     int,
    assists   int,
    penalties int,

    UNIQUE (player_id, season_id, team_id),
    CHECK (goals >= 0 AND assists >= 0 AND penalties >= 0),
    CHECK (penalties <= goals),
    FOREIGN KEY (player_id) REFERENCES Players (person_id),
    FOREIGN KEY (season_id) REFERENCES Seasons (season_id),
    FOREIGN KEY (team_id) REFERENCES Teams (team_id)
);
