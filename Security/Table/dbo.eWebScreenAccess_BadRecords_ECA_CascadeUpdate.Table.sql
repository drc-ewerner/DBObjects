USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebScreenAccess_BadRecords_ECA_CascadeUpdate]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebScreenAccess_BadRecords_ECA_CascadeUpdate](
	[ScreenAccessId] [int] NOT NULL,
	[ProfileId] [int] NOT NULL,
	[PermissionID] [int] NULL
) ON [PRIMARY]
GO
