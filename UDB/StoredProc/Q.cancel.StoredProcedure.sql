USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Q].[cancel]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Q].[cancel] @administrationId int,@documentId int as 
set xact_abort on;
update document.testticket set notTestedCode='Canceled'
where administrationId=@administrationId and documentId=@documentId
and not exists(select * from document.testticketview where administrationId=@administrationId and documentId=@documentId and status='Completed');
if (@@rowcount=0) throw 50011,'completed form',0;
delete testsession.links where administrationId=@administrationId and documentId=@documentId;
insert document.testticketstatus (administrationId,documentid,status)
select @administrationId,@documentId,'Cancel';
GO
