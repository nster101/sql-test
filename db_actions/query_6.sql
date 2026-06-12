WITH cte AS(
    SELECT T.Name,
    T.Stadium,
    T.TeamID,
    G.GameID,
    G.HomeTeamID,
    G.AwayTeamID,
    G.GameDateTime,
    G.HomeScore,
    G.AwayScore,
    locations.PlayedHome,
    locations.PlayedAway,
    results.HomeWin,
    results.HomeLoss,
    results.AwayWin,
    results.AwayLoss,
    scores.DiffScore,
    biggest.BigWin,
    biggest.BigLoss,
    Bigg.bw,
    Bigg.bl
    FROM nba.dbo.Teams as T
    LEFT OUTER JOIN nba.dbo.Games as G
        ON T.TeamID = G.HomeTeamID OR T.TeamID = G.AwayTeamID
    CROSS APPLY(
        VALUES(IIF(T.TeamID = G.HomeTeamID, 1, 0),
               IIF(T.TeamID = G.AwayTeamID, 1, 0)
              ) ) AS locations (PlayedHome, PlayedAway)
    CROSS APPLY (
    VALUES (
        IIF((HomeScore > AwayScore) AND (locations.PlayedHome=1), 1, 0),
        IIF((HomeScore < AwayScore) AND (locations.PlayedHome=1), 1, 0),
        IIF((HomeScore < AwayScore) AND (locations.PlayedAway=1), 1, 0),
        IIF((HomeScore > AwayScore) AND (locations.PlayedAway=1), 1, 0)
            ) )AS results(HomeWin, HomeLoss, AwayWin, AwayLoss)
    CROSS APPLY(
        VALUES (
        ABS(HomeScore - AwayScore)
    )) AS scores(DiffScore)
    CROSS APPLY (
    VALUES(
        IIF(HomeWin = 1 or AwayWin = 1, CONCAT(CAST(HomeScore AS VARCHAR),'-', CAST(AwayScore AS VARCHAR)), NULL),
        IIF(HomeLoss = 1 OR AwayLoss = 1, CONCAT(CAST(AwayScore AS VARCHAR), '-', CAST(HomeScore AS VARCHAR)), NULL))) AS biggest(BigWin, BigLoss)
    CROSS APPLY (
        SELECT biggest.BigWin as bw, biggest.BigLoss as bl
    ) AS Bigg)

SELECT
    cte.Name,
    cte.Stadium,
    SUM(cte.PlayedHome + cte.PlayedAway) AS Played,
    SUM(cte.HomeWin + cte.AwayWin) AS Won,
    SUM(cte.HomeLoss + cte.AwayLoss) AS Lost,
    SUM(cte.PlayedHome) AS [Played Home],
    SUM(cte.PlayedAway) AS [Played Away]
  FROM cte

GROUP BY cte.TeamID, cte.Name, cte.Stadium
ORDER BY [Won] DESC;