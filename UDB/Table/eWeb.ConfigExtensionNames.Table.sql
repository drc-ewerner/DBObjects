USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[ConfigExtensionNames]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[ConfigExtensionNames](
	[NamesID] [int] IDENTITY(1,1) NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[eDirectProject] [varchar](200) NOT NULL,
	[ControlName] [varchar](100) NOT NULL,
	[SortOrder] [int] NOT NULL,
 CONSTRAINT [PK_ConfigExtensionNames_Primary] PRIMARY KEY CLUSTERED 
(
	[NamesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_ConfigExtensionNames] UNIQUE NONCLUSTERED 
(
	[Category] ASC,
	[Name] ASC,
	[eDirectProject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[ConfigExtensionNames]  WITH CHECK ADD  CONSTRAINT [FK_ConfigExtensionRenderOptions] FOREIGN KEY([ControlName])
REFERENCES [eWeb].[ConfigExtensionRenderOptions] ([ControlName])
GO
ALTER TABLE [eWeb].[ConfigExtensionNames] CHECK CONSTRAINT [FK_ConfigExtensionRenderOptions]
GO
