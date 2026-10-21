-- Demo queries showing the seeded data
USE soccer_project;

-- 1. Standings: top 5 teams of the Premier League in the 2024/25 season
SELECT st.position, t.name, st.matches_played, st.wins, st.draws, st.losses, st.goal_difference
FROM Standings st
JOIN Teams t ON t.team_id = st.team_id
JOIN Seasons s ON s.season_id = st.season_id
JOIN Leagues l ON l.league_id = s.league_id
WHERE l.name = 'Premier League'
  AND s.start_year = 2024
  AND st.position <= 5
ORDER BY st.position;

-- 2. Standings: teams that won 25 or more matches
SELECT t.name, st.wins
FROM Standings st
JOIN Teams t ON t.team_id = st.team_id
WHERE st.wins >= 25;

-- 3. Seasons: every league's 2024/25 season
SELECT l.name, s.start_year, s.end_year
FROM Seasons s
JOIN Leagues l ON l.league_id = s.league_id
WHERE s.start_year = 2024;

-- 4. Stadiums: stadiums that hold more than 60,000 people, largest first
SELECT name, city, capacity
FROM Stadiums
WHERE capacity > 60000
ORDER BY capacity DESC;

-- 5. Teams: clubs founded before 1880
SELECT name, year_established
FROM Teams
WHERE year_established < 1880
ORDER BY year_established;
