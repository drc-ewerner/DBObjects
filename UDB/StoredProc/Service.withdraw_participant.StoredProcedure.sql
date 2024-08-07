USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Service].[withdraw_participant]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Service].[withdraw_participant] 
  @participantId varchar(100),
  @incoming nvarchar(max),
  @admins nvarchar(max)
as set xact_abort on;

declare @updateDate datetime=getdate();

declare @keys table (administrationId int,studentId int,withdrawalSite varchar(15));

insert @keys (administrationId,studentId,withdrawalSite)
select s.administrationId,s.studentId,a.withdrawalSite
from openjson(@admins) with (administrationId int,withdrawalSite varchar(15)) a
join core.student s on s.administrationId=a.administrationId and s.participantId=@participantId
where s.districtCode!=a.withdrawalSite;

declare @out table(administrationId int,studentId int,participantId varchar(100),action varchar(10));

update s set districtCode=withdrawalSite,updateDate=@updateDate
output inserted.administrationId,inserted.studentId,@participantId,'withdraw' into @out
from core.student s
join @keys k on k.administrationId=s.administrationId and k.studentId=s.studentId;

select *
from @out o
order by administrationId,studentId;
GO
