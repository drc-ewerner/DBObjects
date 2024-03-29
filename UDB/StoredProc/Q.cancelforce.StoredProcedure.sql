USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Q].[cancelforce]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Q].[cancelforce] @administrationId int,@documentId int as 
set xact_abort on;
update document.testticket set notTestedCode='Canceled'
where administrationId=@administrationId and documentId=@documentId;

delete testsession.links where administrationId=@administrationId and documentId=@documentId;
insert document.testticketstatus (administrationId,documentid,status)
select @administrationId,@documentId,'Cancel';
GO
