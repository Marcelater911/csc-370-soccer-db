use soccer_project;
drop table if exists Country;
create table Country(`country_id` int primary key, `name` varchar(50) not null, `flag_url` varchar(255));