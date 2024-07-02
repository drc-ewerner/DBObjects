USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebUsersToSyncToECA]    Script Date: 7/2/2024 9:42:55 AM ******/
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
