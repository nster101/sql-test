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

-- WITH cte AS (SELECT T.Name                                           AS Name,
--                     T.Stadium                                        AS Stadium,
--                     SUM(homeGames.PlayedHome + awayGames.PlayedAway) AS Played,
--                     SUM(awayGames.AwayWins + homeGames.HomeWins)     AS Won,
--                     SUM(awayGames.AwayLosses + homeGames.HomeLosses) AS Lost,
--                     SUM(homeGames.PlayedHome)                        AS 'Played Home',
--                     SUM(awayGames.PlayedAway)                        AS 'Played Away'
--              FROM nba.dbo.Teams as T,
--                   nba.dbo.Games as G,
--                   nba.dbo.Players as P,
--                   nba.dbo.Team_Player as tp
--                       LEFT OUTER JOIN (SELECT G.HomeTeamID                              AS homeID,
--                                               count(*)                                  AS PlayedHome,
--                                               SUM(IIF(G.HomeScore > G.AwayScore, 1, 0)) AS HomeWins,
--                                               SUM(IIF(G.HomeScore < G.AwayScore, 1, 0)) AS HomeLosses
--                                        GROUP BY G.HomeTeamID) AS homeGames
--                                       ON T.TeamID = homeGames.homeID
--                       LEFT OUTER JOIN (SELECT G.AwayTeamID                              as awayID,
--                                               count(*)                                  as PlayedAway,
--                                               SUM(IIF(G.HomeScore > G.AwayScore, 1, 0)) AS AwayLosses,
--                                               SUM(IIF(G.HomeScore < G.AwayScore, 1, 0)) AS AwayWins
--                                        GROUP BY G.AwayTeamID) AS awayGames
--                                       ON T.TeamID = awayID)
-- SELECT
--     cte.Name,
--     cte.Stadium
-- FROM cte
-- GROUP BY cte.Name, cte.Stadium
-- -- WITH cte AS(
-- --     SELECT
-- --         T.Name,
-- --         T.Stadium,
-- --         T.TeamID,
-- --         G.HomeTeamID,
-- --         G.AwayTeamID,
-- --         G.HomeScore,
-- --         G.AwayScore,
-- --         G.MVPPlayerID,
-- --         P.PlayerID,
-- --         tp.TeamID AS tID,
-- --         tp.PlayerID AS pID
-- --     FROM nba.dbo.Teams as T,
-- --          nba.dbo.Games as G,
-- --          nba.dbo.Players as P,
-- --          nba.dbo.Team_Player as tp
-- -- )
-- -- SELECT
-- --     cte.Name,
-- --     cte.Stadium
-- -- FROM cte
-- -- GROUP BY cte.Name, cte.Stadium
-- --
-- --
-- -- -- SELECT
-- -- --     Teams.Name AS Name,
-- -- --     Teams.Stadium AS Stadium,
-- -- --     SUM(homeGames.PlayedHome + awayGames.PlayedAway) AS Played,
-- -- --     SUM(awayGames.AwayWins + homeGames.HomeWins) AS Won,
-- -- --     SUM(awayGames.AwayLosses + homeGames.HomeLosses) AS Lost,
-- -- --     SUM(homeGames.PlayedHome) AS 'Played Home',
-- -- --     SUM(awayGames.PlayedAway) AS 'Played Away'
-- -- -- FROM Teams
-- -- --     LEFT OUTER JOIN (
-- -- --         SELECT
-- -- --             Games.HomeTeamID AS homeID,
-- -- --                count(*) AS PlayedHome,
-- -- --                SUM(IIF(HomeScore > AwayScore, 1, 0)) AS HomeWins,
-- -- --                SUM(IIF(HomeScore < AwayScore, 1, 0)) AS HomeLosses
-- -- --         FROM nba.dbo.Games AS Games
-- -- --         GROUP BY Games.HomeTeamID
-- -- --     ) AS homeGames
-- -- --             ON Teams.TeamID = homeGames.homeID
-- -- --     LEFT OUTER JOIN (
-- -- --         SELECT Games.AwayTeamID as awayID,
-- -- --                count(*) as PlayedAway,
-- -- --                SUM(IIF(HomeScore > AwayScore, 1, 0)) AS AwayLosses,
-- -- --                SUM(IIF(HomeScore < AwayScore, 1, 0)) AS AwayWins
-- -- --         FROM nba.dbo.Games AS Games
-- -- --         GROUP BY Games.AwayTeamID) AS awayGames
-- -- --         ON Teams.TeamID = awayID
-- -- -- GROUP BY Name, Stadium, PlayedHome, PlayedAway
-- -- -- ORDER BY Won DESC;
