USE master
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'TestTemplate8Db')
BEGIN
  CREATE DATABASE TestTemplate8Db;
END;
GO

USE TestTemplate8Db;
GO

IF NOT EXISTS (SELECT 1
                 FROM sys.server_principals
                WHERE [name] = N'TestTemplate8Db_Login' 
                  AND [type] IN ('C','E', 'G', 'K', 'S', 'U'))
BEGIN
    CREATE LOGIN TestTemplate8Db_Login
        WITH PASSWORD = '<DB_PASSWORD>';
END;
GO  

IF NOT EXISTS (select * from sys.database_principals where name = 'TestTemplate8Db_User')
BEGIN
    CREATE USER TestTemplate8Db_User FOR LOGIN TestTemplate8Db_Login;
END;
GO  


EXEC sp_addrolemember N'db_datareader', N'TestTemplate8Db_User';
GO

EXEC sp_addrolemember N'db_datawriter', N'TestTemplate8Db_User';
GO

EXEC sp_addrolemember N'db_ddladmin', N'TestTemplate8Db_User';
GO
