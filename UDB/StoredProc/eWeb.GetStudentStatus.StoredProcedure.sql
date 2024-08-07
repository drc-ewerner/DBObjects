USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentStatus]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [eWeb].[GetStudentStatus] 
(
	@AdminID int,
	@DistrictCode varchar(15),
	@SchoolCode varchar(50),
	@Grade VARCHAR(2),
	@ContentArea varchar(50)
)
WITH RECOMPILE
as

-- Lookup timezone offset
declare @Offset as int
select @Offset=eWeb.GetConfigExtensionValue(@AdminId,'eWeb','Timezone.Offset',NULL)

select [LastName]
      ,[FirstName]
      ,[Grade]
      ,[ContentArea]
	  ,Status=case when max(status) <> min(status) 
	                 then 'In Progress'
                   else min(status)
              end
      ,StartTime=min(DATEADD(hh, @Offset, [StartTime]))
      ,EndTime=case when max(status) = min(status) and max(status) = 'Completed' 
	                  then max(DATEADD(hh, @Offset, [EndTime])) 
					else null 
			   end
	,LocalStartTime=min(LocalStartTime) 
	,LocalEndTime=case when max(status) = min(status) and max(status) = 'Completed' 
                  then max([LocalEndTime]) 
			else null 
	   end
	,min(DATEDIFF(hh, [StartTime], LocalStartTime)) AS LocalOffset
	,Timezone=min(TT.Timezone)
from [Document].[TestTicketView] TT
inner join [Core].[Document] D
on TT.AdministrationID = D.AdministrationID and  TT.DocumentID = D.DocumentID
inner join [TestSession].[Links] SL
on TT.AdministrationID = SL.AdministrationID and TT.DocumentID = SL.DocumentID
inner join [Core].[Student] S
on TT.AdministrationID = S.AdministrationID and D.StudentID = S.StudentID
inner join [Scoring].[Tests] T
on TT.AdministrationID = T.AdministrationID and TT.Test = T.Test
where TT.AdministrationID = @AdminID
	and (S.DistrictCode = @DistrictCode or @DistrictCode ='')
	and (S.SchoolCode = @SchoolCode or @SchoolCode = '')
	and (S.Grade = @Grade or @Grade = '')
	and (T.ContentArea = @ContentArea or @ContentArea = '')
group by S.StudentID, LastName, FirstName, Grade, ContentArea
order by Grade, LastName, FirstName, ContentArea

GO
