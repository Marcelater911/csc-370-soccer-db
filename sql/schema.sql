use soccer_project;
drop table if exists League;
drop table if exists Country;
create table Country(country_id int primary key, name varchar(50) not null, flag_url varchar(255));
create table League(league_id int primary key, name varchar(50) not null, country_id int not null, num_of_teams int, ucl_spots int, uel_spots int, foreign key(country_id) references Country(country_id));