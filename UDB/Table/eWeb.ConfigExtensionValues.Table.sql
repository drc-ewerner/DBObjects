USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[ConfigExtensionValues]    Script Date: 7/2/2024 9:12:03 AM ******/
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
ALTER TABLE [eWeb].[ConfigExtensionValues]  WITH CHECK ADD  CONSTRAINT [fk_ConfigExtensionValues_ConfigExtensionNames] FOREIGN KEY([NamesID])
REFERENCES [eWeb].[ConfigExtensionNames] ([NamesID])
GO
ALTER TABLE [eWeb].[ConfigExtensionValues] CHECK CONSTRAINT [fk_ConfigExtensionValues_ConfigExtensionNames]
GO
