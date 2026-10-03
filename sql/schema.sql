use soccer_project;
drop table if exists Referees;
drop table if exists Stadiums;
drop table if exists Leagues;
drop table if exists Countries;
create table Countries(country_id int primary key, name varchar(50) not null, flag_url varchar(255));
create table Leagues(league_id int primary key, name varchar(50) not null, country_id int not null, num_of_teams int, ucl_spots int, uel_spots int, relegation_spots int, foreign key(country_id) references Countries(country_id));
create table Stadiums(stadium_id int primary key, name varchar(50) not null, location varchar(50), capacity int);
create table Referees(referee_id int primary key, name varchar(50) not null, country_id int);
