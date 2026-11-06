USE soccer_project;


CREATE OR REPLACE VIEW v_standings AS
SELECT
    se.league_id,
    st.season_id,
    st.team_id,
    st.wins,
    st.losses,
    st.draws,
    st.goal_difference,
    st.promotion,
    st.relegation,

    (3 * st.wins + st.draws) AS points,

    (st.wins + st.losses + st.draws) AS matches_played,

    RANK() OVER (
        PARTITION BY se.league_id, st.season_id
        ORDER BY
            (3 * st.wins + st.draws) DESC,
            st.goal_difference DESC
    ) AS position

FROM Standings st
JOIN Seasons se
    ON st.season_id = se.season_id;




CREATE OR REPLACE VIEW v_player_ages AS
SELECT
    p.person_id,
    p.first_name,
    p.last_name,
    p.team_id,
    pl.position,
    pl.jersey_num,
    p.date_of_birth,
    p.country_id,

    TIMESTAMPDIFF(
        YEAR,
        p.date_of_birth,
        CURDATE()
    ) AS age

FROM Person p
JOIN Players pl
    ON p.person_id = pl.person_id;



CREATE OR REPLACE VIEW v_match_results AS
SELECT
    f.match_id,
    f.home_team_id,
    f.away_team_id,
    f.season_id,
    f.stadium_id,
    f.match_referee,
    f.utc_kickoff,

    s.full_time_home,
    s.full_time_away,
    s.half_time_home,
    s.half_time_away,

    CASE
        WHEN s.full_time_home > s.full_time_away
            THEN f.home_team_id

        WHEN s.full_time_away > s.full_time_home
            THEN f.away_team_id

        ELSE NULL
    END AS winner_id

FROM Fixtures f
LEFT JOIN Scores s
    ON f.match_id = s.match_id;
