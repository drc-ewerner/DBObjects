USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[Usp_SC_Users_Count]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Usp_SC_Users_Count]
	@District nvarchar(4),
	@School nvarchar(3),
    @LastName nvarchar(256),
    @FirstName nvarchar(256),
    @Email nvarchar(256),
    @AdminEmail nvarchar(256)
AS
BEGIN
	 Select Count(*) userCount from dbo.vw_SC_UserList where
	 ((District = @District) or (@District = '')) 
		and ((SChool = @School) or (@School = '')) 
		and (FirstName like '%' + @FirstName +  '%') 
		and (LastName like '%' + @LastName + '%') 
		and (Email Like '%' + @Email + '%') 
		and (Email <> @AdminEmail)
END
GO
