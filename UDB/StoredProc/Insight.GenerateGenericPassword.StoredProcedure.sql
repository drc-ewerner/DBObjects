USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GenerateGenericPassword]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Insight].[GenerateGenericPassword]
	@AdministrationID int,
	@StartDate datetime,
	@EndDate datetime

as set nocount on;

declare @pwd table(n int not null,Password varchar(20) not null);
declare @exists char(1)='N'
declare @getone char(1)='Y'

while @getone = 'Y' begin
	delete @pwd
	insert @pwd
	select * from Insight.GeneratePassword(@AdministrationID,'',1)

	select @exists='Y' from @pwd p
	inner join Config.GenericPassword g on g.Password=p.Password

	if (@exists is null or @exists!='Y') begin set @getone='N' end
end

set @EndDate=DATEADD(d,1,@EndDate)
set @EndDate=dateadd(s,-1,@EndDate)

insert Config.GenericPassword
select @AdministrationID,Password,@StartDate,@EndDate,getdate()
from @pwd
GO
