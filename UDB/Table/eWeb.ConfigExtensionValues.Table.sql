USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[ConfigExtensionValues]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[ConfigExtensionValues](
	[ValuesID] [int] IDENTITY(1,1) NOT NULL,
	[NamesID] [int] NOT NULL,
	[PossibleValue] [varchar](1000) NOT NULL,
	[SortOrder] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[ConfigExtensionValues]  WITH CHECK ADD  CONSTRAINT [FK_ConfigExtensionValues] FOREIGN KEY([NamesID])
REFERENCES [eWeb].[ConfigExtensionNames] ([NamesID])
GO
ALTER TABLE [eWeb].[ConfigExtensionValues] CHECK CONSTRAINT [FK_ConfigExtensionValues]
GO
