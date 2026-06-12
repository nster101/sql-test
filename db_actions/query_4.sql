SELECT
    Teams.Name AS Name,
    Teams.Stadium AS Stadium,
    SUM(homeGames.PlayedHome + awayGames.PlayedAway) AS Played,
    SUM(awayGames.AwayWins + homeGames.HomeWins) AS Won,
    SUM(awayGames.AwayLosses + homeGames.HomeLosses) AS Lost,
    SUM(homeGames.PlayedHome) AS 'Played Home',
    SUM(awayGames.PlayedAway) AS 'Played Away'
FROM Teams
    LEFT OUTER JOIN (
        SELECT
            Games.HomeTeamID AS homeID,
               count(*) AS PlayedHome,
               SUM(IIF(HomeScore > AwayScore, 1, 0)) AS HomeWins,
               SUM(IIF(HomeScore < AwayScore, 1, 0)) AS HomeLosses
        FROM nba.dbo.Games AS Games
        GROUP BY Games.HomeTeamID
    ) AS homeGames
            ON Teams.TeamID = homeGames.homeID
    LEFT OUTER JOIN (
        SELECT Games.AwayTeamID as awayID,
               count(*) as PlayedAway,
               SUM(IIF(HomeScore > AwayScore, 1, 0)) AS AwayLosses,
               SUM(IIF(HomeScore < AwayScore, 1, 0)) AS AwayWins
        FROM nba.dbo.Games AS Games
        GROUP BY Games.AwayTeamID) AS awayGames
        ON Teams.TeamID = awayID
GROUP BY Name, Stadium, PlayedHome, PlayedAway
ORDER BY Won DESC;
