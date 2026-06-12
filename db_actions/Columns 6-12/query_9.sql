
WITH st AS(
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
    HT.Stadium AS GameStadium,
    IIF(HomeScore > AwayScore, 1, 0) AS HomeWin,
    IIF(AwayScore > HomeScore, 1, 0) AS AwayWin,
    HT.Stadium AS HomeStadium,
    AT.Stadium AS AwayStadium,
    ABS(HomeScore-AwayScore) AS AbsDiff
FROM nba.dbo.Games AS G
INNER JOIN nba.dbo.Teams AS HT
    ON HT.TeamID = G.HomeTeamID
INNER JOIN nba.dbo.Teams as AT
    ON AT.TeamID = G.AwayTeamID
INNER JOIN nba.dbo.Players AS P
    ON P.PlayerID = G.MVPPlayerID
),
cte AS (
    SELECT
        TeamName = ca.TeamName,
        IsHome = ca.IsHome,
        IsWin = ca.IsWin,
        TeamScore = ca.TeamScore,
        OppScore = ca.OppScore,
        ScoreDiff = ca.TeamScore - ca.OppScore,
        GameDate = st.Date,
        st.HomeWin,
        st.AwayWin,
        st.GameStadium,
        st.HomeStadium,
        st.AwayStadium,
        GameMVP = st.PlayerName
        FROM st
    CROSS APPLY(
    VALUES
        (st.HomeTeam, 1, IIF(st.HomeScore > st.AwayScore, 1, 0), st.HomeScore, st.AwayScore),
        (st.AwayTeam, 0, IIF(st.AwayScore > st.HomeScore, 1, 0), st.AwayScore, st.HomeScore)
    )AS ca(TeamName, IsHome, IsWin, TeamScore, OppScore)
),
TeamStats AS (
    SELECT
        TeamName,
        Stadium = MAX(IIF(IsHome = 1, HomeStadium, AwayStadium)),
        Played = COUNT(*),
        Won = SUM(IsWin),
        Lost = SUM(IIF(IsWin = 0, 1, 0)),
        PlayedHome = SUM(IsHome),
        PlayedAway = SUM(IIF(IsHome = 0, 1, 0))
    FROM cte
    GROUP BY TeamName
)
SELECT
    ts.TeamName AS Name,
    ts.Stadium,
    ts.Played,
    ts.PlayedHome as [Played Home],
    ts.PlayedAway AS [Played Away],
    ts.Won,
    ts.Lost,
    bw.BiggestWin AS [Biggest Win],
    bl.BiggestLoss AS [Biggest Loss],
    lg.LastGameStadium AS [Last Game Stadium],
    CONVERT(VARCHAR(19), lg.LastGameDate, 120) AS [Last Game Date],
    mvp.MVPPlayer AS MVP
FROM TeamStats ts
OUTER APPLY (
    SELECT TOP 1 CAST(TeamScore AS VARCHAR) + '-' + CAST(OppScore AS VARCHAR) AS BiggestWin FROM cte c2
    WHERE c2.TeamName = ts.TeamName AND c2.IsWin = 1
    ORDER BY c2.ScoreDiff DESC, c2.GameDate DESC
) bw
OUTER APPLY (
    SELECT TOP 1 CAST(TeamScore AS VARCHAR) + '-' + CAST(OppScore AS VARCHAR) AS BiggestLoss
    FROM cte c2
    WHERE c2.TeamName = ts.TeamName AND c2.IsWin = 0
    ORDER BY c2.ScoreDiff ASC, c2.GameDate DESC
) bl

OUTER APPLY (
    SELECT TOP 1 GameStadium AS LastGameStadium, GameDate AS LastGameDate
    FROM cte c2
    WHERE c2.TeamName = ts.TeamName
    ORDER BY c2.GameDate DESC
) lg
OUTER APPLY (
    SELECT TOP 1 GameMVP AS MVPPlayer
    FROM cte c2
    WHERE c2.TeamName = ts.TeamName AND c2.IsWin = 1
    GROUP BY c2.GameMVP
    ORDER BY COUNT(*) DESC, c2.GameMVP ASC
) mvp
ORDER BY
    ts.Won DESC,
    ts.TeamName ASC;
