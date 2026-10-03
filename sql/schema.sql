use soccer_project;
drop table if exists Scorers; 
-- drop table if exists Matches;
drop table if exists Seasons;
drop table if exists Players;
drop table if exists Coaches;
-- drop table if exists Teams;
drop table if exists Referees;
drop table if exists Stadiums;
drop table if exists Leagues;
drop table if exists Countries;
create table Countries(country_id int primary key, name varchar(50) not null, flag_url varchar(255));
create table Leagues(league_id int primary key, name varchar(50) not null, country_id int not null, num_of_teams int, ucl_spots int, uel_spots int, relegation_spots int, foreign key(country_id) references Countries(country_id));
create table Stadiums(stadium_id int primary key, name varchar(50) not null, location varchar(50), capacity int);
create table Referees(referee_id int primary key, name varchar(50) not null, country_id int);
-- teams check if they drop coach id
create table Coaches(coach_id int primary key, name varchar(50) not null, team_id int, country_id int);
create table Players(player_id int primary key, team_id int, name varchar(50) not null, position varchar(50), date_of_birth date, country_id int);
create table Seasons(season_id int primary key, league_id int, year char(4));
-- match see if merge with scores
create table Scorers(scorer_id int primary key, player_id int, season_id int, league_id int, goals int, assists int, penlties int);
