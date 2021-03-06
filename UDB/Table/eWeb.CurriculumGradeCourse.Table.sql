USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[CurriculumGradeCourse]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[CurriculumGradeCourse](
	[ContentAreaCode] [varchar](10) NOT NULL,
	[GradeCourseCode] [varchar](10) NOT NULL,
	[GradeCourseDescr] [varchar](30) NOT NULL,
	[SortOrder] [smallint] NULL,
 CONSTRAINT [PK_CurriculumGradeCourse_1] PRIMARY KEY CLUSTERED 
(
	[ContentAreaCode] ASC,
	[GradeCourseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[CurriculumGradeCourse]  WITH CHECK ADD  CONSTRAINT [FK_CurriculumGradeCourse_CurriculumContentArea1] FOREIGN KEY([ContentAreaCode])
REFERENCES [eWeb].[CurriculumContentArea] ([ContentAreaCode])
GO
ALTER TABLE [eWeb].[CurriculumGradeCourse] CHECK CONSTRAINT [FK_CurriculumGradeCourse_CurriculumContentArea1]
GO
