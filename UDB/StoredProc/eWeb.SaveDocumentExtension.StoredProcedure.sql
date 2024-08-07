USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveDocumentExtension]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[SaveDocumentExtension]
@AdministrationID INT,
@DocumentID INT,
@Name VARCHAR(50),
@Value VARCHAR(100)

AS

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
select @AdministrationID,e.InputID,e.EntryID,d.StudentID,@DocumentID,'Update-Transactional'
from @entry e
inner join Core.Document d on e.AdministrationID=d.AdministrationID and d.DocumentID=@DocumentID;


insert Journal.Extensions (AdministrationID,InputID,EntryID,Name,Value)
select AdministrationID,InputID,EntryID,'Document'+'$'+@Name,@Value
from @entry;
/* End Added on 5/16/2011 kptak*/

IF EXISTS
(
	select * from Document.Extensions
	where
		[AdministrationID] = @AdministrationID AND
		[DocumentID] = @DocumentID AND
		[Name] = @Name
)
BEGIN
	UPDATE
		[Document].[Extensions]
	SET
		[Value] = @Value
	WHERE
		[AdministrationID] = @AdministrationID AND
		[DocumentID] = @DocumentID AND
		[Name] = @Name
END
ELSE
BEGIN
	INSERT [Document].[Extensions] ([AdministrationID], [DocumentID], [Name], [Value])
	SELECT @AdministrationID, @DocumentID,  @Name, @Value
END
GO
