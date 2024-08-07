USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebScreenAccess]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebScreenAccess](
	[ScreenAccessId] [int] IDENTITY(1,1) NOT NULL,
	[ProfileId] [int] NOT NULL,
	[PermissionID] [int] NULL,
 CONSTRAINT [PK_eWebScreenAccess] PRIMARY KEY CLUSTERED 
(
	[ScreenAccessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eWebScreenAccess]  WITH CHECK ADD  CONSTRAINT [FK_eWebPermissionAccess_eWebPermission] FOREIGN KEY([PermissionID])
REFERENCES [dbo].[eWebScreen] ([PermissionID])
GO
ALTER TABLE [dbo].[eWebScreenAccess] CHECK CONSTRAINT [FK_eWebPermissionAccess_eWebPermission]
GO
ALTER TABLE [dbo].[eWebScreenAccess]  WITH CHECK ADD  CONSTRAINT [FK_eWebScreenAccess_eWebUserProfile] FOREIGN KEY([ProfileId])
REFERENCES [dbo].[eWebUserProfile] ([ProfileId])
GO
ALTER TABLE [dbo].[eWebScreenAccess] CHECK CONSTRAINT [FK_eWebScreenAccess_eWebUserProfile]
GO
