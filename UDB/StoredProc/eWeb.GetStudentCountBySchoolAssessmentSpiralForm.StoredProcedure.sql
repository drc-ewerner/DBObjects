USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentCountBySchoolAssessmentSpiralForm]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [eWeb].[GetStudentCountBySchoolAssessmentSpiralForm]
@AdministrationID int
as
begin
	select ts.districtcode, ts.schoolcode, st.contentarea, AssessmentText=isnull(tl.[Description],tl.Level), 
	ts.mode, se.value as SpiralingRule,
	count(distinct convert(varchar,tsl.testsessionid) + '-' + convert(varchar,tsl.studentid)) as NbrStudents
	from document.testticket tt
	inner join testsession.links tsl on tt.administrationid = tsl.administrationid and tt.documentid = tsl.documentid
	inner join core.testsession ts on ts.administrationid = tsl.administrationid and ts.testsessionid = tsl.testsessionid
	inner join scoring.tests st on st.administrationid = tt.administrationid and st.test = tt.test
	inner join scoring.testlevels tl on tl.administrationid = tt.administrationid and tl.test = tt.test and tl.level = tt.level
	left join site.extensions se on se.administrationid = ts.administrationid and se.districtcode = ts.districtcode and se.schoolcode = ts.schoolcode 
		and category = 'Spiral' and ts.test + '.' + ts.level + '.FORMNAME' = se.name
	left join Config.Extensions ext on ext.AdministrationID=tl.AdministrationID and ext.Category='eWeb' and ext.Name=tl.Test + '.' + tl.Level + '.Hide'
	left join Config.Extensions ext2 on ext2.AdministrationID=tl.AdministrationID and ext2.Category='eWeb' and ext2.Name=st.ContentArea + '.Hide'
	where tt.administrationid = @AdministrationID 
	and st.ContentArea not like '$%' and tl.Description not like '$%'
	and isnull(ext.Value, 'N') = 'N' and isnull(ext2.Value, 'N') = 'N' 
	group by ts.districtcode, ts.schoolcode, st.contentarea, tl.[Description],tl.Level, ts.mode, se.value
end
GO
