USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetPrintTestItemRequests]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	CREATE procedure [eWeb].[GetPrintTestItemRequests]
		@AdminID int,
		@SessionID integer
	AS

	/*Create Missing Records for 'Test' request type only.*/
	Insert Into [insight].[PrintOnDemandRequest] (AdministrationID, RequestType, Form, PassageID, PassageIndicator, ItemID, Position, StudentID, TestSessionID, ViewCount, CreateDate)
	Select Distinct
		cts.AdministrationID,
		case when se.name = 'Online.LargePrint' then 'Large' else 'Test' end as RequestType,
		case when stfp.Form Is Null then dtt.Form else stfp.Form end as [Form], --make sure it's the base form
		'' as PassageID,
		'' as passageIndicator,
		'' as ItemID,
		'' as Position,
		tsl.StudentID,
		tsl.TestSessionID,
		0 as ViewCount,
		GETDATE()
	From [Core].[TestSession] cts --May not need core.testsessions at all here...
	inner join [TestSession].[Links] tsl
		on cts.AdministrationID = tsl.AdministrationID
		and cts.TestSessionID = tsl.TestSessionID
	inner join [Document].[TestTicket] dtt
		on tsl.AdministrationID = dtt.AdministrationID
		and tsl.DocumentID = dtt.DocumentID
	inner join [Scoring].[Tests] st
		on cts.AdministrationID = st.AdministrationID
		and cts.Test = st.Test
	inner join [Student].[Extensions] se
		on se.AdministrationID = tsl.AdministrationID
		and se.StudentID = tsl.StudentID
		and se.Category = st.ContentArea
		and se.Name in ('Online.PrintTest', 'Online.PrintTestFee', 'Online.LargePrint',
						--for NV
						'Online.JAPrintTest','Online.DualLanguageSpanishPaper','Online.StackedTranslation')
		and se.Value = 'Y'
	left outer join [insight].[PrintOnDemandRequest] pod
		on tsl.AdministrationID = pod.AdministrationID
		and tsl.StudentID = pod.StudentID
		and tsl.TestSessionID = pod.TestSessionID
	left outer join [Scoring].[TestFormParts] stfp
		on dtt.AdministrationID = stfp.AdministrationID
		and dtt.Test = stfp.Test
		and dtt.Level = stfp.Level
		and dtt.Form = stfp.FormPart
	where cts.AdministrationID = @AdminID
	and cts.TestSessionID = @SessionID
	and pod.AdministrationID IS NULL
	

	/*Return all data for this session*/
	Select 
		pod.AdministrationID, 
		pod.RequestID, 
		pod.RequestType, 
		pod.Form, 
		pod.PassageID, 
		pod.PassageIndicator, 
		pod.ItemID, 
		pod.Position, 
		pod.StudentID, 
		pod.TestSessionID, 
		pod.ViewCount, 
		pod.CreateDate,
		cs.FirstName,
		cs.LastName
	From [insight].[PrintOnDemandRequest] pod
	inner join [Core].[Student] cs
		on pod.AdministrationID = cs.AdministrationID
		and pod.StudentID = cs.StudentID
	Where pod.AdministrationID = @AdminID
		and pod.TestSessionID = @SessionID


GO
