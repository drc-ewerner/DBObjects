USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebUsersToSyncToECA]    Script Date: 11/21/2023 8:39:10 AM ******/
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
