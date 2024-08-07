USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateStudentAccommodations]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[UpdateStudentAccommodations]
 
@AdministrationID INT,
@StudentID INT,
@Category VARCHAR(50),
@Name VARCHAR(50),
@Value VARCHAR(100),
@IsRemoving BIT
 
AS
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;
 
begin tran
 
if (@IsRemoving=1 and @Value='Y')
BEGIN
	set @Value='';

	delete Student.Extensions
	where AdministrationID=@AdministrationID and StudentID=@StudentID and Category=@Category and Name=@Name;
END

if (@IsRemoving=0 and @Value='Y')
BEGIN

	
	DELETE FROM Student.Extensions where AdministrationID=@AdministrationID and StudentID=@StudentID and Category=@Category and Name=@Name
	BEGIN
		insert Student.Extensions
			(AdministrationID,StudentID,Category,Name,Value)
		select
			@AdministrationID,@StudentID,@Category,@Name,@Value;
	END
END
 
declare @entry table(InputID int not null,EntryID int not null);
 
insert Journal.TransactionalEntries (AdministrationID,InputID)
output inserted.InputID,inserted.EntryID into @entry
select AdministrationID,InputID
from Config.TransactionalSources
where AdministrationID=@AdministrationID and Source='eDirect';
 
insert Journal.Entries (AdministrationID,InputID,EntryID,EntryDate)
select @AdministrationID,InputID,EntryID,getdate()
from @entry;
 
insert Journal.Links (AdministrationID,InputID,EntryID,StudentID,DocumentID,LinkInfo)
select @AdministrationID,InputID,EntryID,@StudentID,null,'Update-Transactional'
from @entry;
 
insert Journal.Extensions (AdministrationID,InputID,EntryID,Name,Value)
select @AdministrationID,InputID,EntryID,@Category+'$'+@Name,@Value
from @entry;
 
commit tran
GO
