USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[TestScoreTemplates]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[TestScoreTemplates](
	[AdministrationID] [int] NOT NULL,
	[TemplateName] [varchar](100) NOT NULL,
	[ScoreBaseName] [varchar](250) NOT NULL,
	[ScoreDescription] [varchar](1000) NULL,
	[TemplateConfig] [xml] NULL,
 CONSTRAINT [pk_TestScoreTemplates] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TemplateName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
