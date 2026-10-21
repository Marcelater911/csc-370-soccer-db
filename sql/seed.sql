-- Seed data script
USE soccer_project;

-- Countries (country_id is assigned by AUTO_INCREMENT)
INSERT INTO Countries (name, flag_url) VALUES
('England', 'https://media.api-sports.io/flags/gb-eng.svg'),
('Spain', 'https://media.api-sports.io/flags/es.svg'),
('Germany', 'https://media.api-sports.io/flags/de.svg'),
('Italy', 'https://media.api-sports.io/flags/it.svg'),
('France', 'https://media.api-sports.io/flags/fr.svg');

-- Leagues: league_id is the API's id; country_id is looked up from the Countries table by country name
INSERT INTO Leagues (league_id, name, country_id) VALUES
(39,  'Premier League',   (SELECT country_id FROM Countries WHERE name = 'England')),
(40,  'Championship',     (SELECT country_id FROM Countries WHERE name = 'England')),
(140, 'La Liga',          (SELECT country_id FROM Countries WHERE name = 'Spain')),
(141, 'Segunda División', (SELECT country_id FROM Countries WHERE name = 'Spain')),
(78,  'Bundesliga',       (SELECT country_id FROM Countries WHERE name = 'Germany')),
(79,  '2. Bundesliga',    (SELECT country_id FROM Countries WHERE name = 'Germany')),
(135, 'Serie A',          (SELECT country_id FROM Countries WHERE name = 'Italy')),
(136, 'Serie B',          (SELECT country_id FROM Countries WHERE name = 'Italy')),
(61,  'Ligue 1',          (SELECT country_id FROM Countries WHERE name = 'France')),
(62,  'Ligue 2',          (SELECT country_id FROM Countries WHERE name = 'France'));

-- Stadiums: stadium_id is the API's id


