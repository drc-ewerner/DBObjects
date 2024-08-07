USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[UpdateTestSession]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Insight].[UpdateTestSession]
@AdministrationID INT, 
@TestSessionID INT, 
@Test VARCHAR (50), 
@Level VARCHAR (20), 
@StartTime DATETIME, 
@EndTime DATETIME, 
@Name VARCHAR (100), 
@Mode VARCHAR (50),
@teacherID int,
@Form varchar(20),
@ScoringOption VARCHAR (50) = NULL,
@OptionalItems VARCHAR (50) = NULL

AS
set nocount on; set transaction isolation level read uncommitted;

update Core.TestSession 
	set Test=@Test,
	Level=@Level,
	StartTime=@StartTime,
	EndTime=@EndTime,
	Name=@Name, 
	Mode=@Mode,
	TeacherID=case when @teacherID=0 then null else @teacherID end,
	Form=@Form,
	UpdateDate=getdate(),
    ScoringOption=@ScoringOption,
	OptionalItems=@OptionalItems
where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID
GO
