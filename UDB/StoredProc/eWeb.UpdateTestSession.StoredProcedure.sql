USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateTestSession]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[UpdateTestSession]
@AdministrationID INT, @TestSessionID INT, @Test VARCHAR (50), @Level VARCHAR (20), @StartTime DATETIME, @EndTime DATETIME, @Name VARCHAR (100), @Mode VARCHAR (50), @TestMonitoring varchar(50) = NULL,
@TestAccess varchar(10) = NULL
AS
update Core.TestSession set Test=@Test,Level=@Level,StartTime=@StartTime,EndTime=@EndTime,Name=@Name, Mode=@Mode, UpdateDate=getdate(),TestMonitoring = NULLIF(@TestMonitoring, ''),
	TestAccessControl = NULLIF(@TestAccess, '')
where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID
GO
