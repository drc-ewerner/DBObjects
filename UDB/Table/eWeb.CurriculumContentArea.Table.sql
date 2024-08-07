USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[CurriculumContentArea]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[CurriculumContentArea](
	[ContentAreaCode] [varchar](10) NOT NULL,
	[ContentAreaDescr] [varchar](30) NOT NULL,
	[LearningProgressionPath] [varchar](1200) NULL,
	[IsVisible] [bit] NULL,
 CONSTRAINT [pk_CurriculumContentArea] PRIMARY KEY CLUSTERED 
(
	[ContentAreaCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
