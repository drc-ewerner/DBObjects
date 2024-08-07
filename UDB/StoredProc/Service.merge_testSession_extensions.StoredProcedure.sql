USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Service].[merge_testSession_extensions]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Service].[merge_testSession_extensions]
@administrationId int,
@testSessionId int,
@incoming nvarchar(max)
as set xact_abort on;

with i as (
  select administrationId=@administrationId,testSessionId=@testSessionId,name,value
  from openjson(@incoming) with (teacherFirstName varchar(100),teacherMiddleName varchar(100),teacherLastName varchar(100),teacherId varchar(100),teacherEmail varchar(100),teacherUsername varchar(100)) i
  unpivot (value for name in (teacherFirstName,teacherMiddleName,teacherLastName,teacherId,teacherEmail,teacherUsername)) u
)
merge testsession.extensions t
using i on i.administrationId=t.administrationId and i.testSessionId=t.testSessionId and i.name=t.name
when matched and i.value is null then delete
when matched then update set value=i.value
when not matched and i.value is not null then insert (administrationId,testSessionId,name,value) values (i.administrationId,i.testSessionId,i.name,i.value);
GO
