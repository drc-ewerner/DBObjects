USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DropProc_IfExists]    Script Date: 1/12/2022 1:30:38 PM ******/
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
