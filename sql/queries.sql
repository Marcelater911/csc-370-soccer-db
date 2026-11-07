-- Phase 4: Advanced SQL Queries & Performance Analysis
USE soccer_project;

-- 1. DISTINCT & Subquery in FROM: Countries that have at least one historic team (founded before 1900)
SELECT DISTINCT c.name AS country_name
FROM Countries c
JOIN (
    SELECT t.country_id 
    FROM Teams t 
    WHERE t.year_established < 1900
) historic_teams ON c.country_id = historic_teams.country_id;

-- 2. Scalar Subquery: Teams with a stadium capacity greater than the global average capacity
SELECT t.name, st.name AS stadium_name, st.capacity
FROM Teams t
JOIN Stadiums st ON t.stadium_id = st.stadium_id
WHERE st.capacity > (SELECT AVG(capacity) FROM Stadiums);

-- 3. Correlated Subquery: Teams that have more wins than the average wins of all teams in their specific season
SELECT s.team_id, t.name, s.season_id, s.wins
FROM Standings s
JOIN Teams t ON s.team_id = t.team_id
WHERE s.wins > (
    SELECT AVG(sub_s.wins)
    FROM Standings sub_s
    WHERE sub_s.season_id = s.season_id
);

-- 4. ANY / ALL: Players who have scored more goals than ALL players in a specific season/team configuration
SELECT p.first_name, p.last_name, p.team_id, pss.goals
FROM PlayerSeasonStats pss
JOIN Person p ON pss.player_id = p.person_id
WHERE pss.goals > ALL (
    SELECT sub_pss.goals
    FROM PlayerSeasonStats sub_pss
    WHERE sub_pss.season_id = 1 AND sub_pss.team_id <> pss.team_id
);

-- 5. GROUP BY + HAVING: Seasons where the average team goal difference is strictly greater than 0, filtering for competitive tiers
SELECT season_id, COUNT(team_id) AS total_teams, AVG(goal_difference) AS avg_gd
FROM Standings
GROUP BY season_id
HAVING AVG(goal_difference) >= 0 AND COUNT(team_id) >= 18;

-- 6A. Subquery approach (Teams with no standings row in the 2024/25 season)
SELECT t.team_id, t.name
FROM Teams t
WHERE t.team_id NOT IN (
    SELECT st.team_id
    FROM Standings st
    JOIN Seasons s ON st.season_id = s.season_id
    WHERE s.start_year = 2024
);

-- 6B. Converted to LEFT JOIN / NOT NULL equivalent
SELECT t.team_id, t.name
FROM Teams t
LEFT JOIN (
    SELECT st.team_id
    FROM Standings st
    JOIN Seasons s ON st.season_id = s.season_id
    WHERE s.start_year = 2024
) active_st ON t.team_id = active_st.team_id
WHERE active_st.team_id IS NULL;


-- Step A: Run EXPLAIN ANALYZE on a non-FK column before adding an index
EXPLAIN ANALYZE 
SELECT * FROM Standings WHERE wins = 20;

-- Step B: Add an index to a non-FK column (Standings.wins)
CREATE INDEX idx_standings_wins ON Standings(wins);

-- Step C: Run EXPLAIN ANALYZE again to compare execution cost/plans
EXPLAIN ANALYZE 
SELECT * FROM Standings WHERE wins = 20;