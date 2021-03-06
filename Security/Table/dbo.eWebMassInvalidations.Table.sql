USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebMassInvalidations]    Script Date: 1/12/2022 1:43:31 PM ******/
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
