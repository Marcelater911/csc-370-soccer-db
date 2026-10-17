DROP DATABASE IF EXISTS soccer_project;
CREATE DATABASE soccer_project;
USE soccer_project;

DROP TABLE IF EXISTS PlayerSeasonStats;
DROP TABLE IF EXISTS Standings;
DROP TABLE IF EXISTS MatchStatistics;
DROP TABLE IF EXISTS Scores;
DROP TABLE IF EXISTS Fixtures;
DROP TABLE IF EXISTS Seasons;
DROP TABLE IF EXISTS Players;
DROP TABLE IF EXISTS Coaches;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Referees;
DROP TABLE IF EXISTS Stadiums;
DROP TABLE IF EXISTS Leagues;
DROP TABLE IF EXISTS Countries;

CREATE TABLE Countries (
    country_id int PRIMARY KEY,
    name       varchar(50) NOT NULL,
    flag_url   varchar(255)
);

CREATE TABLE Person (
    person_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    country_id INT,

    FOREIGN KEY (country_id)
        REFERENCES Countries(country_id)
);

CREATE TABLE Leagues (
    league_id        int PRIMARY KEY,
    name             varchar(50) NOT NULL,
    country_id       int NOT NULL,
    num_of_teams     int,
    FOREIGN KEY (country_id) REFERENCES Countries (country_id)
);

CREATE TABLE Stadiums (
    stadium_id int PRIMARY KEY,
    name       varchar(50) NOT NULL,
    location   varchar(50),
    capacity   int
);

CREATE TABLE Referees (
    person_id int PRIMARY KEY,

    FOREIGN KEY(person_id) 
        REFERENCES Person(person_id)
        ON DELETE CASCADE
        
    
);

CREATE TABLE Teams (
    team_id          int PRIMARY KEY,
    name             varchar(50) NOT NULL,
    league_id        int,
    stadium_id       int,
    year_established int,
    FOREIGN KEY (league_id) REFERENCES Leagues (league_id),
    FOREIGN KEY (stadium_id) REFERENCES Stadiums (stadium_id)
);

CREATE TABLE Coaches (
    person_id   int PRIMARY KEY,
    
    team_id    int UNIQUE,
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

CREATE TABLE Players (
    person_id     int PRIMARY KEY,
    team_id       int,
    position      varchar(50),
    FOREIGN KEY (person_id) REFERENCES Person (person_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

CREATE TABLE Seasons (
    season_id int PRIMARY KEY,
    league_id int,
    year      char(4),
    FOREIGN KEY (league_id) REFERENCES Leagues (league_id)
);

CREATE TABLE Fixtures (
    match_id        int PRIMARY KEY,
    home_team_id    int,
    away_team_id    int,
    season_id       int,
    stadium_id      int,
    winner_id       int,
    match_referee_id int,
    utc_kickoff     date,
    FOREIGN KEY (home_team_id) REFERENCES Teams (team_id),
    FOREIGN KEY (away_team_id) REFERENCES Teams (team_id),
    FOREIGN KEY (season_id) REFERENCES Seasons (season_id),
    FOREIGN KEY (stadium_id) REFERENCES Stadiums (stadium_id),
    FOREIGN KEY (winner_id) REFERENCES Teams (team_id),
    FOREIGN KEY (match_referee_id) REFERENCES Referees (person_id)
);

CREATE TABLE Scores (
    score_id        int PRIMARY KEY,
    match_id        int UNIQUE,
    full_time_home  int,
    full_time_away  int,
    half_time_home  int,
    half_time_away  int,
    FOREIGN KEY (match_id) REFERENCES Fixtures (match_id)
);

CREATE TABLE MatchStatistics (
    statistic_id        int PRIMARY KEY,
    match_id             int UNIQUE,
    home_total_shots     int,
    away_total_shots     int,
    home_shot_accuracy   float(3,2),
    away_shot_accuracy   float(3,2),
    home_corners         int,
    away_corners         int,
    home_offsides        int,
    away_offsides        int,
    home_tackles         int,
    away_tackles         int,
    home_total_passes    int,
    away_total_passes    int,
    home_possession      float(3,2),
    FOREIGN KEY (match_id) REFERENCES Fixtures (match_id)
);

CREATE TABLE Standings (
    standing_id     int PRIMARY KEY,
    season_id       int,
    team_id         int,
    position        int,
    wins            int,
    losses          int,
    draws           int,
    goal_difference int,
    promotion       boolean,
    relegation      boolean,
    FOREIGN KEY (season_id) REFERENCES Seasons (season_id),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

CREATE TABLE PlayerSeasonStats (
    scorer_id int PRIMARY KEY,
    team_id int,
    person_id int,
    season_id int,
    goals     int,
    assists   int,
    penalties int,

    UNIQUE (person_id, season_id, team_id),
    CHECK (goals >= 0 AND assists >= 0 AND penalties >= 0),
    CHECK (penalties <= goals),
    FOREIGN KEY (season_id) REFERENCES Seasons (season_id),
    FOREIGN KEY (person_id) REFERENCES Players (person_id),
    FOREIGN KEY (team_id) REFERENCES Teams (team_id)
);
