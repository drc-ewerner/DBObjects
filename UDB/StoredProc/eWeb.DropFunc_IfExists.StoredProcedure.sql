USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DropFunc_IfExists]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc [eWeb].[DropFunc_IfExists]
@FunctionFullName varchar(500)
as

/*Drop older versions of the procedure if they exist*/
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'' + @FunctionFullName + '') AND type in (N'FN'))
BEGIN
	Declare @SQL As varchar(5000)
	Set @SQL = 'DROP FUNCTION ' + @FunctionFullName
	EXEC (@SQL)
END
GO
