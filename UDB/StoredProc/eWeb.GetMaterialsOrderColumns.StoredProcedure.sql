USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetMaterialsOrderColumns]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create Procedure [eWeb].[GetMaterialsOrderColumns]
	@AdministrationID integer,
	@AppletCode varchar(10)
	
As
	
Select distinct itm.[Description] from eWeb.EnrollmentOrder o inner join
eWeb.EnrollmentOrderItem oi on o.OrderID=oi.OrderID inner join
eWeb.EnrollmentItem itm on oi.ItemID=itm.ItemID
where o.ExportDate is null and oi.[Count] >0 and o.AdminID=@AdministrationID and o.AppletCode=@AppletCode
ORDER BY itm.[Description] asc
GO
