USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveStudentExtension]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[SaveStudentExtension]
@AdministrationID INT,
@StudentID INT,
@Category VARCHAR(50),
@Name VARCHAR(50),
@Value VARCHAR(100)

AS

set nocount on;

/* Added on 5/16/2011 kptak*/
declare @entry table(AdministrationID int not null,InputID int not null,EntryID int not null);

insert Journal.TransactionalEntries (AdministrationID,InputID)
output inserted.AdministrationID,inserted.InputID,inserted.EntryID into @entry
select AdministrationID,InputID
from Config.TransactionalSources
where AdministrationID=@AdministrationID and Source='eDirect';

insert Journal.Entries (AdministrationID,InputID,EntryID,EntryDate)
select AdministrationID,InputID,EntryID,getdate() from @entry;

insert Journal.Links (AdministrationID,InputID,EntryID,StudentID,DocumentID,LinkInfo)
select @AdministrationID,InputID,EntryID,@StudentID,null,'Update-Transactional'
from @entry;

insert Journal.Extensions (AdministrationID,InputID,EntryID,Name,Value)
select AdministrationID,InputID,EntryID,@Category+'$'+@Name,@Value
from @entry;
/* End Added on 5/16/2011 kptak*/

IF EXISTS
(
	select * from Student.Extensions
	where
		[AdministrationID] = @AdministrationID AND
		[StudentID] = @StudentID AND
		[Category] = @Category AND
		[Name] = @Name
)
BEGIN
	UPDATE
		[Student].[Extensions]
	SET
		[Value] = @Value
	WHERE
		[AdministrationID] = @AdministrationID AND
		[StudentID] = @StudentID AND
		[Category] = @Category AND
		[Name] = @Name
END
ELSE
BEGIN
	INSERT [Student].[Extensions] ([AdministrationID], [StudentID], [Category], [Name], [Value])
	SELECT @AdministrationID, @StudentID, @Category, @Name, @Value
END
GO
