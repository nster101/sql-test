USE nba;
GO

CREATE OR ALTER VIEW dbo.SummaryTable AS
SELECT
    G.GameID,
    HT.Name AS HomeTeam,
    AT.Name AS AwayTeam,
    G.HomeScore,
    G.AwayScore,
    G.HomeTeamID,
    G.AwayTeamID,
    G.MVPPlayerID,
    P.Name as PlayerName,
    G.GameDateTime as Date,
    ABS(HomeScore-AwayScore) AS AbsDiff
FROM nba.dbo.Games AS G
INNER JOIN nba.dbo.Teams AS HT
    ON HT.TeamID = G.HomeTeamID
INNER JOIN nba.dbo.Teams as AT
    ON AT.TeamID = G.AwayTeamID
INNER JOIN nba.dbo.Players AS P
    ON P.PlayerID = G.MVPPlayerID
GO
