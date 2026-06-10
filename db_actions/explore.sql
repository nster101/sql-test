SELECT *
    FROM nba.dbo.Teams AS Teams
        ORDER BY TeamID ASC;
SELECT TOP 10 *
    FROM nba.dbo.Games AS Games
        ORDER BY GameID ASC;
SELECT TOP 10 *
    FROM nba.dbo.Players AS Players
        ORDER BY PlayerID ASC;
SELECT TOP 10 *
    FROM nba.dbo.Team_Player as Team_Player
        ORDER BY PlayerID ASC;
-- SELECT * FROM nba.dbo.__MigrationHistory;
-- SELECT * FROM nba.dbo.sysdiagrams;

