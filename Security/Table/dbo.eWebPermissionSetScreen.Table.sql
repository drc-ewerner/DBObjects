USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebPermissionSetScreen]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebPermissionSetScreen](
	[PermissionSetScreenID] [int] IDENTITY(1,1) NOT NULL,
	[PermissionSetID] [int] NOT NULL,
	[PermissionID] [int] NOT NULL,
 CONSTRAINT [PK_PermissionSetScreen] PRIMARY KEY CLUSTERED 
(
	[PermissionSetScreenID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eWebPermissionSetScreen]  WITH CHECK ADD  CONSTRAINT [FK_eWebPermissionSetScreen_eWebPermissionSet] FOREIGN KEY([PermissionSetID])
REFERENCES [dbo].[eWebPermissionSet] ([PermissionSetID])
GO
ALTER TABLE [dbo].[eWebPermissionSetScreen] CHECK CONSTRAINT [FK_eWebPermissionSetScreen_eWebPermissionSet]
GO
ALTER TABLE [dbo].[eWebPermissionSetScreen]  WITH CHECK ADD  CONSTRAINT [FK_eWebPermissionSetScreen_eWebScreen] FOREIGN KEY([PermissionID])
REFERENCES [dbo].[eWebScreen] ([PermissionID])
GO
ALTER TABLE [dbo].[eWebPermissionSetScreen] CHECK CONSTRAINT [FK_eWebPermissionSetScreen_eWebScreen]
GO
