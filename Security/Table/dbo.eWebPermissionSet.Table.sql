USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebPermissionSet]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebPermissionSet](
	[PermissionSetID] [int] IDENTITY(1,1) NOT NULL,
	[PermissionSetName] [nvarchar](50) NOT NULL,
	[AdminID] [int] NOT NULL,
	[RoleID] [int] NOT NULL,
 CONSTRAINT [PK_eWebPermissionSet] PRIMARY KEY CLUSTERED 
(
	[PermissionSetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eWebPermissionSet]  WITH CHECK ADD  CONSTRAINT [FK_eWebPermissionSet_eWebRole] FOREIGN KEY([RoleID])
REFERENCES [dbo].[eWebRole] ([RoleId])
GO
ALTER TABLE [dbo].[eWebPermissionSet] CHECK CONSTRAINT [FK_eWebPermissionSet_eWebRole]
GO
