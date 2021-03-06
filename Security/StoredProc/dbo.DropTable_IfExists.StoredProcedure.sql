USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[DropTable_IfExists]    Script Date: 1/12/2022 2:05:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[DropTable_IfExists]
@TableFullName varchar(500)
as

/*Drop older versions of the procedure if they exist*/
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'' + @TableFullName + '') AND type in (N'S', N'U'))
BEGIN
	Declare @SQL As varchar(5000)
	Set @SQL = 'DROP TABLE ' + @TableFullName
	EXEC (@SQL)
END
GO
