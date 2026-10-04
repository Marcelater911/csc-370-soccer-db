DROP DATABASE IF EXISTS soccer_project;
CREATE DATABASE soccer_project;
USE soccer_project;

DROP TABLE IF EXISTS Scorers;
DROP TABLE IF EXISTS Standings;
DROP TABLE IF EXISTS MatchStatistics;
DROP TABLE IF EXISTS Scores;
DROP TABLE IF EXISTS `Matches`;
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

CREATE TABLE Leagues (
    league_id        int PRIMARY KEY,
    name             varchar(50) NOT NULL,
    country_id       int NOT NULL,
    num_of_teams     int,
    ucl_spots        int,
    uel_spots        int,
    relegation_spots int,
    FOREIGN KEY (country_id) REFERENCES Countries (country_id)
);

CREATE TABLE Stadiums (
    stadium_id int PRIMARY KEY,
    name       varchar(50) NOT NULL,
    location   varchar(50),
    capacity   int
);

CREATE TABLE Referees (
    referee_id int PRIMARY KEY,
    name       varchar(50) NOT NULL,
    country_id int
    FOREIGN KEY (country_id) REFERENCES Countries (country_id)
);

CREATE TABLE Teams (
    team_id          int PRIMARY KEY,
    name             varchar(50) NOT NULL,
    league_id        int,
    stadium_id       int,
    year_established int
    FOREIGN KEY (league_id) REFERENCES Leagues (league_id)
    FOREIGN KEY (stadium_id) REFERENCES Stadiums (stadium_id)
);

CREATE TABLE Coaches (
    coach_id   int PRIMARY KEY,
    name       varchar(50) NOT NULL,
    team_id    int,
    country_id int
);

CREATE TABLE Players (
    player_id     int PRIMARY KEY,
    team_id       int,
    name          varchar(50) NOT NULL,
    position      varchar(50),
    date_of_birth date,
    country_id    int
    FOREIGN KEY (country_id) REFERENCES Country (country_id)
);

CREATE TABLE Seasons (
    season_id int PRIMARY KEY,
    league_id int,
    year      char(4)
    FOREIGN KEY (league_id) REFERENCES Leagues (league_id)
);

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

CREATE TABLE Scores (
    score_id        int PRIMARY KEY,
    match_id        int,
    full_time_home  int,
    full_time_away  int,
    half_time_home  int,
    half_time_away  int
);

CREATE TABLE MatchStatistics (
    statistic_id        int PRIMARY KEY,
    match_id             int,
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
    away_possession      float(3,2)
);

CREATE TABLE Standings (
    standing_id     int PRIMARY KEY,
    league_id       int,
    season_id       int,
    team_id         int,
    position        int,
    wins            int,
    losses          int,
    draws           int,
    points          int,
    goal_difference int,
    games_played    int,
    promotion       boolean,
    relegation      boolean
);

CREATE TABLE Scorers (
    scorer_id int PRIMARY KEY,
    player_id int,
    season_id int,
    league_id int,
    goals     int,
    assists   int,
    penalties int
);
