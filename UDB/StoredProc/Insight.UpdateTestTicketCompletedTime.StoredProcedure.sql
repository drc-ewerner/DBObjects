USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[UpdateTestTicketCompletedTime]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Insight].[UpdateTestTicketCompletedTime] 
	@AdministrationId INT,
	@UserName VARCHAR(50),
	@Password VARCHAR(50),
	@CompletedTime DATETIME

AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	/*
	UPDATE Document.TestTicket SET
		EndTime = @CompletedTime
	WHERE
		AdministrationID = @AdministrationId
		AND UserName LIKE @UserName
		AND Password LIKE @Password
	*/
	
	declare @DocumentID int;
	declare @Status varchar(20);
	
	set @DocumentID=(
		select DocumentID
		from Document.TestTicket
		where AdministrationID=@AdministrationId
		and UserName=@UserName
		and Password=@Password
	);
	set @Status=(
		select top(1) Status
		from Document.TestTicketStatus
		where AdministrationID=@AdministrationId
		and DocumentID=@DocumentID
		order by StatusTime desc
	);
	
	insert Document.TestTicketStatus (AdministrationID, DocumentID, StatusTime, Status)
	select @AdministrationId, @DocumentID, @CompletedTime, @Status;
	
END
GO
