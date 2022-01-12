USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[CurriculumKeyword]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[CurriculumKeyword](
	[CurriculumID] [int] NOT NULL,
	[Keyword] [varchar](500) NOT NULL,
 CONSTRAINT [PK_CurriculumKeyword] PRIMARY KEY CLUSTERED 
(
	[CurriculumID] ASC,
	[Keyword] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[CurriculumKeyword]  WITH CHECK ADD  CONSTRAINT [FK_CurriculumKeyword_Curriculum] FOREIGN KEY([CurriculumID])
REFERENCES [eWeb].[Curriculum] ([CurriculumID])
ON DELETE CASCADE
GO
ALTER TABLE [eWeb].[CurriculumKeyword] CHECK CONSTRAINT [FK_CurriculumKeyword_Curriculum]
GO
