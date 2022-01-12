USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebUsersToSyncToECA]    Script Date: 1/12/2022 1:43:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebUsersToSyncToECA](
	[UserID] [uniqueidentifier] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[IsProcessed] [bit] NOT NULL
) ON [PRIMARY]
GO
