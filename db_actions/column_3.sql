SELECT
    Teams.Name AS Name,
    Teams.Stadium AS Stadium,
    SUM(homeGames.[Played Home]) AS [Played Home],
    SUM(awayGames.[Played Away]) AS [Played Away]
FROM Teams
    LEFT OUTER JOIN (
        SELECT Games.HomeTeamID AS homeID,
               count(*) AS [Played Home]
        FROM nba.dbo.Games AS Games
        GROUP BY Games.HomeTeamID) AS homeGames
            ON Teams.TeamID = homeID
    LEFT OUTER JOIN (
        SELECT Games.AwayTeamID as awayID,
               count(*) as [Played Away]
        FROM nba.dbo.Games AS Games
        GROUP BY Games.AwayTeamID) AS awayGames
        ON Teams.TeamID = awayID
GROUP BY Name, Stadium, [Played Home], [Played Away]
