USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[CurriculumGradeCourse]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[CurriculumGradeCourse](
	[ContentAreaCode] [varchar](10) NOT NULL,
	[GradeCourseCode] [varchar](10) NOT NULL,
	[GradeCourseDescr] [varchar](30) NOT NULL,
	[SortOrder] [smallint] NULL,
 CONSTRAINT [pk_CurriculumGradeCourse] PRIMARY KEY CLUSTERED 
(
	[ContentAreaCode] ASC,
	[GradeCourseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[CurriculumGradeCourse]  WITH CHECK ADD  CONSTRAINT [fk_CurriculumGradeCourse_CurriculumContentArea] FOREIGN KEY([ContentAreaCode])
REFERENCES [eWeb].[CurriculumContentArea] ([ContentAreaCode])
GO
ALTER TABLE [eWeb].[CurriculumGradeCourse] CHECK CONSTRAINT [fk_CurriculumGradeCourse_CurriculumContentArea]
GO
