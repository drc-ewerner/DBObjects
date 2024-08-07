USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[Curriculum]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[Curriculum](
	[CurriculumID] [int] IDENTITY(1,1) NOT NULL,
	[ContentAreaCode] [varchar](10) NOT NULL,
	[GradeCourseCode] [varchar](10) NOT NULL,
	[UnitID] [varchar](10) NOT NULL,
	[UnitTitle] [varchar](100) NOT NULL,
	[LessonID] [varchar](14) NOT NULL,
	[LessonTitle] [varchar](100) NOT NULL,
	[LessonFile] [varchar](1200) NOT NULL,
	[HasResources] [bit] NOT NULL,
	[ResourceFilePath] [varchar](1200) NULL,
	[Status] [varchar](10) NULL,
 CONSTRAINT [pk_Curriculum] PRIMARY KEY NONCLUSTERED 
(
	[CurriculumID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[Curriculum]  WITH CHECK ADD  CONSTRAINT [fk_Curriculum_CurriculumGradeCourse] FOREIGN KEY([ContentAreaCode], [GradeCourseCode])
REFERENCES [eWeb].[CurriculumGradeCourse] ([ContentAreaCode], [GradeCourseCode])
GO
ALTER TABLE [eWeb].[Curriculum] CHECK CONSTRAINT [fk_Curriculum_CurriculumGradeCourse]
GO
