USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DropProc_IfExists]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc [eWeb].[DropProc_IfExists]
@ProcedureFullName varchar(500) --Example Value = '[eWeb].[DropProc_IfExists]'
as

/*Drop older versions of the procedure if they exist*/
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'' + @ProcedureFullName + '') AND type in (N'P', N'PC'))
BEGIN
	Declare @SQL As varchar(5000)
	Set @SQL = 'DROP PROCEDURE ' + @ProcedureFullName
	EXEC (@SQL)
END
GO
