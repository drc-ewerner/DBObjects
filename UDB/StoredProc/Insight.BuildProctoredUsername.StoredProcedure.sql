USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[BuildProctoredUsername]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Insight].[BuildProctoredUsername]
	@AdministrationID int,
	@StudentID int,
	@Username varchar(50) output

as set nocount on;

declare @lastname nvarchar(100),@firstname nvarchar(100),@birthmonth char(2),@birthday char(2),@birthyear char(4);
declare @nameportion varchar(200);

select @lastname=LastName,@firstname=FirstName,@birthmonth=RIGHT('0' + CAST(datepart(mm,BirthDate) AS VARCHAR),2),
	@birthday=RIGHT('0' + CAST(datepart(dd,BirthDate) AS VARCHAR),2),@birthyear=datepart(yyyy,BirthDate) 
from Core.Student where AdministrationID=@AdministrationID and StudentID=@StudentID;

set @lastname = cast(@lastname as varchar(100)) Collate SQL_Latin1_General_CP1253_CI_AI
set @firstname = cast(@firstname as varchar(100)) Collate SQL_Latin1_General_CP1253_CI_AI

while PATINDEX('%[^a-z]%',@lastname) > 0
	begin
		set @lastname = STUFF(@lastname,PATINDEX('%[^a-z]%',@lastname),1,'')
	end;
while PATINDEX('%[^a-z]%',@firstname) > 0
	begin
		set @firstname = STUFF(@firstname,PATINDEX('%[^a-z]%',@firstname),1,'')
	end;
set @nameportion=@firstname+@lastname
set @Username=left(@nameportion,44)+isnull(@birthmonth,'')+isnull(@birthyear,'')
--set @Username=left(@firstname,1)+@lastname+@birthmonth+@birthday+@birthyear
GO
