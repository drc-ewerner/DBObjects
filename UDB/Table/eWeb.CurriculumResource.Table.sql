USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[CurriculumResource]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[CurriculumResource](
	[CurriculumID] [int] NOT NULL,
	[ResourceTitle] [varchar](50) NOT NULL,
	[ResourceFileName] [varchar](255) NOT NULL,
 CONSTRAINT [PK_CurriculumResource] PRIMARY KEY CLUSTERED 
(
	[CurriculumID] ASC,
	[ResourceTitle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[CurriculumResource]  WITH CHECK ADD  CONSTRAINT [FK_CurriculumResource_Curriculum] FOREIGN KEY([CurriculumID])
REFERENCES [eWeb].[Curriculum] ([CurriculumID])
ON DELETE CASCADE
GO
ALTER TABLE [eWeb].[CurriculumResource] CHECK CONSTRAINT [FK_CurriculumResource_Curriculum]
GO
