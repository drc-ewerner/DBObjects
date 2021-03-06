USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[CreateNewBlankMaterialOrders]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [eWeb].[CreateNewBlankMaterialOrders]
	@AdministrationID as integer,
	@OrderID as integer
as

declare @NewOrderID integer


	Insert into eWeb.EnrollmentOrder
	(
		AdminID,
		StatusID,
		DistrictCode,
		SchoolCode,
		LastUpdateDate,
		AppletCode,
		ExportDate
	)
	Select @AdministrationID,1,DistrictCode,SchoolCode,getdate(),AppletCode,null from
	eWeb.EnrollmentOrder where AdminId=@AdministrationID and orderid=@orderid
	
	Select @NewOrderID=Scope_Identity()
	
	Insert Into eWeb.EnrollmentOrderItem
	(
		OrderID,
		ItemID,
		[Count],
		LastUpdateDate
	)
	Select @NewOrderID,ItemID,0,getdate() from 
	eWeb.EnrollmentOrderItem where OrderID=@OrderID
	
	Insert into eWeb.EnrollmentOrderQuestionAnswer
	(
		orderId,
		QuestionID,
		Answer,
		LastUpdateDate
	)
	Select @NewOrderID,QuestionID,'',getdate() from eWeb.EnrollmentOrderQuestionAnswer
	where orderID=@OrderID
GO
