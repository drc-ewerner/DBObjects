USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Service].[ensure_testSession]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Service].[ensure_testSession]
@registrationId varchar(100),
@administrationId int,
@incoming nvarchar(max)
as set xact_abort on;

declare @testSessionId int,@doExtensions int;

select @testSessionId=testSessionId from core.testsession (nolock) where registrationId=@registrationId;

if (@testSessionId is null) begin

  insert core.testsession (administrationId,testSessionId,districtCode,schoolCode,test,level,startTime,endTime,name,mode,userId,registrationId,testMonitoring,testAccessControl)
  select @administrationId,next value for core.testSession_seqEven,districtCode,schoolCode,test,level,startTime=isnull(startTime,cast(getdate() as date)),endTime=isnull(endTime,dateadd(year,1,cast(getdate() as date))),name,mode='Online',userId,registrationId=@registrationId,testMonitoring,testAccessControl
  from openjson(@incoming) with (districtCode varchar(15),schoolCode varchar(15),test varchar(50),level varchar(20),startTime datetime,endTime datetime,name varchar(100),userId varchar(100),testMonitoring varchar(100),testAccessControl varchar(100))
  where not exists(select * from core.testsession (nolock) x where x.registrationId=@registrationId);

  set @doExtensions=@@rowcount;

  select @testSessionId=testSessionId from core.testsession (nolock) where registrationId=@registrationId;

end;

if (@doExtensions=1) exec service.merge_testSession_extensions @administrationId,@testSessionId,@incoming;

select testSessionId=@testSessionId;
GO
