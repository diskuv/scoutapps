--https://www.w3schools.com/sql/sql_count.asp

-- Looks at all the columns in the table
-- Always use this unless specified otherwise
-- SELECT * From raw_match_data

--USE for searching for a specific team
    SELECT * From raw_match_data AS specificTeam
    WHERE team_number = 2930;

--USE for searching inside a specific match
    SELECT * From raw_match_data AS matchData
    WHERE match_number = 1;

-- Getting Averages
    SELECT AVG(tele_amp_score) AS average
    FROM raw_match_data
    WHERE team_number = 2930;

--USE for getting the count of something
    SELECT COUNT(endgame_climb) AS count
    FROM raw_match_data
    WHERE endgame_climb = "DID_NOT_ATTEMPT" AND team_number = 2930;


--Getting all information to fill out scout sheet

INSERT INTO raw_match_data ()
VALUES ()


--DELETE all record in the table
--ONLY use at start of a new competition
DELETE FROM raw_match_data;