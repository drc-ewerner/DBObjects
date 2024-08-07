USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTicketsBySession]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetTicketsBySession]


@AdministrationID int,
@TestSessionID int

AS

DECLARE @isMultiSelect BIT
SELECT @isMultiSelect = CASE eWeb.GetConfigExtensionValue(@AdministrationID, 'eWeb', 'ConfigUI.UseMultiSelectSessionModal', 'N')
					WHEN 'Y' THEN 1
					ELSE 0
				  END

--2/15/2011 - changed Times to dimply return nullable date
--4/15/2011 - added non-assessed code

select
	distinct t.AdministrationID,t.DocumentID,t.Test,t.Level,t.Form,t.UserName,t.Password,t.Spiraled,t.NotTestedCode,
	t.Status,s.StudentID,s.FirstName,s.LastName,s.MiddleName,	
	StartTime=t.StartTime,
	EndTime=t.EndTime,
	t.[LocalStartTime], 
	t.[LocalEndTime], 
	DATEDIFF(hh,t.[StartTime],t.[LocalStartTime]) AS LocalOffset,
	UnlockTime = t.UnlockTime,
	ts.TestSessionID,
	Accommodations=coalesce(left(Accommodations,len(Accommodations)-1),''),
	PartName = case 
				WHEN @isMultiSelect = 1 THEN tf.FormSessionName
				when fp.PartName is null then '' 
				else 'Module ' + fp.PartName 
			   end,
	NoAssessedCode = cast( na.[Value] as int),
	NonPublicEnrolled = cast( np.[Value] as bit),
	t.Timezone
from Core.TestSession ts 
inner join Scoring.Tests st on st.AdministrationID=ts.AdministrationID and st.Test=ts.Test
inner join TestSession.Links k on k.AdministrationID=ts.AdministrationID and k.TestSessionID=ts.TestSessionID
inner join Document.TestTicketView t on t.AdministrationID=k.AdministrationID and t.DocumentID=k.DocumentID 
LEFT OUTER JOIN Scoring.TestForms tf ON tf.AdministrationID = t.AdministrationID AND tf.Test = t.Test AND tf.[Level] = t.[Level] AND tf.Form = t.Form
left outer join Scoring.TestFormParts fp on t.AdministrationId = fp.AdministrationId and t.Test = fp.Test and t.[Level] = fp.[Level] and t.PartName = fp.PartName
inner join Core.Student s on s.AdministrationID=ts.AdministrationID and s.StudentID=k.StudentID
left outer join Document.Extensions na on na.AdministrationID=t.AdministrationID and na.DocumentID=t.DocumentID and na.[Name] = 'NonAssessedCd'
left outer join Document.Extensions np on np.AdministrationID=t.AdministrationID and np.DocumentID=t.DocumentID and np.[Name] = 'NonPublicEnrolled'
outer apply (
	select sx.DisplayName+', ' from xref.studentextensionnames sx 
		inner join Student.Extensions x
		on sx.category = x.category and sx.name = x.name and sx.AdministrationID = x.AdministrationID
		inner join config.extensions cx
		on cx.Category='Accommodation.Online' and cx.AdministrationID = x.AdministrationID and cx.Name = x.Category + '.' + x.name
		where x.AdministrationID=t.AdministrationID and x.StudentID=k.StudentID and x.Category=st.ContentArea and x.Value='Y' 
		order by sx.DisplayName 		
	for xml path('')) sx(Accommodations)
where ts.AdministrationID=@AdministrationID and ts.TestSessionID=@TestSessionID
order By Status desc,Test,LastName,FirstName


GO
