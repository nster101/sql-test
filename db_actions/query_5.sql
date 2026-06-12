WITH cte AS(
    SELECT T.Name,
    T.Stadium,
    cab.PlayedHome,
    cab.PlayedAway,
    ca.HomeWins,
    ca.HomeLosses,
    ca.AwayWins,
    ca.AwayLosses

    FROM nba.dbo.Teams as T
    LEFT OUTER JOIN nba.dbo.Games as G
        ON T.TeamID = G.HomeTeamID OR T.TeamID = G.AwayTeamID
    CROSS APPLY(
        VALUES(IIF(T.TeamID = G.HomeTeamID, 1, 0),
               IIF(T.TeamID = G.AwayTeamID, 1, 0)
              ) ) AS cab (PlayedHome, PlayedAway)
    CROSS APPLY (
    VALUES (
        IIF((HomeScore > AwayScore) AND (cab.PlayedHome=1), 1, 0),
        IIF((HomeScore < AwayScore) AND (cab.PlayedHome=1), 1, 0),
        IIF((HomeScore > AwayScore) AND (cab.PlayedAway=1), 1, 0),
        IIF((HomeScore < AwayScore) AND (cab.PlayedAway=1), 1, 0)
) )AS ca(HomeWins, HomeLosses, AwayWins, AwayLosses))

SELECT
    cte.Name,
    cte.Stadium,
    SUM(cte.HomeWins) AS [Won Home],
    SUM(cte.HomeLosses) AS [Lost Home],
    SUM(cte.AwayWins) AS [Won Away],
    SUM(cte.AwayLosses) AS [Lost Away],
    SUM(cte.PlayedHome) AS [Played Home],
    SUM(cte.PlayedAway) AS [Played Away]
FROM cte
GROUP BY cte.Name, cte.Stadium;
