USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebScreenAccess_BadRecords_ECA_CascadeUpdate]    Script Date: 1/12/2022 1:43:31 PM ******/
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
