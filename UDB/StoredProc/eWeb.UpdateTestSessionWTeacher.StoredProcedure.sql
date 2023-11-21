USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateTestSessionWTeacher]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[UpdateTestSessionWTeacher]
@AdministrationID INT, 
@TestSessionID INT, 
@Test VARCHAR (50), 
@Level VARCHAR (20), 
@StartTime DATETIME, 
@EndTime DATETIME, 
@Name VARCHAR (100), 
@Mode VARCHAR (50),
@teacherID int,
@ClassCode varchar(15) = '',
@OptionalItems varchar(50) = NULL,
@TestMonitoring varchar(50) = NULL,
@TestAccess varchar(10) = NULL

AS

update Core.TestSession 
	set Test=@Test,
	Level=@Level,
	StartTime=@StartTime,
	EndTime=@EndTime,
	Name=@Name, 
	Mode=@Mode,
	TeacherID=case when @teacherID=0 then null else @teacherID end,
	ClassCode = @ClassCode,
	UpdateDate=getdate(),
	OptionalItems = NULLIF(@OptionalItems, ''),
	TestMonitoring = NULLIF(@TestMonitoring, ''),
	TestAccessControl = NULLIF(@TestAccess, '')
where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID
GO
