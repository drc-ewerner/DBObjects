USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ResetMaterialsOrdersToZero]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create Procedure [eWeb].[ResetMaterialsOrdersToZero]
	@AdministationID integer,
	@AppletCode varchar(10)
As
Update eWeb.EnrollmentOrder
    set ExportDate=getdate(),
    LastUpdateDate=getdate()
where (ExportDate is null) and (AppletCode=@AppletCode)  and AdminID=@AdministationID
GO
