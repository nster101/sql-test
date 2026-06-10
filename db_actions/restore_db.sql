RESTORE DATABASE nba
FROM DISK = '/var/opt/mssql/backups/nba.bak'
WITH
    MOVE 'nba' TO '/var/opt/mssql/data/nba.mdf',
    MOVE 'nba_log' TO '/var/opt/mssql/data/nba_log.ldf',
    REPLACE,
    STATS = 10;