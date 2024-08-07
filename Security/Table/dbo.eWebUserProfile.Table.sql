USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebUserProfile]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebUserProfile](
	[ProfileId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Role] [nvarchar](50) NULL,
	[AdminId] [int] NULL,
	[DistrictCode] [nvarchar](50) NULL,
	[SchoolCode] [nvarchar](50) NULL,
	[RoleID] [int] NULL,
 CONSTRAINT [PK_eWebUserProfile] PRIMARY KEY CLUSTERED 
(
	[ProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eWebUserProfile]  WITH CHECK ADD  CONSTRAINT [FK_eWebUserProfile__aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eWebUserProfile] CHECK CONSTRAINT [FK_eWebUserProfile__aspnet_Users]
GO
ALTER TABLE [dbo].[eWebUserProfile]  WITH CHECK ADD  CONSTRAINT [FK_eWebUserProfiles_eWebRole] FOREIGN KEY([RoleID])
REFERENCES [dbo].[eWebRole] ([RoleId])
GO
ALTER TABLE [dbo].[eWebUserProfile] CHECK CONSTRAINT [FK_eWebUserProfiles_eWebRole]
GO
