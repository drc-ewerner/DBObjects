USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebMassInvalidations]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebMassInvalidations](
	[Email] [nvarchar](256) NOT NULL,
	[UserID] [uniqueidentifier] NULL,
	[IsProcessed] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eWebMassInvalidations] ADD  DEFAULT ((0)) FOR [IsProcessed]
GO
