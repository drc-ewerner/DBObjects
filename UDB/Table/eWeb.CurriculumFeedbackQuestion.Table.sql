USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[CurriculumFeedbackQuestion]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[CurriculumFeedbackQuestion](
	[ContentAreaCode] [varchar](10) NOT NULL,
	[SortOrder] [smallint] NOT NULL,
	[QuestionTypeCode] [varchar](10) NOT NULL,
	[QuestionText] [varchar](500) NOT NULL,
	[CommentText] [varchar](500) NULL,
 CONSTRAINT [pk_CurriculumFeedbackQuestion] PRIMARY KEY CLUSTERED 
(
	[ContentAreaCode] ASC,
	[SortOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[CurriculumFeedbackQuestion]  WITH CHECK ADD  CONSTRAINT [fk_CurriculumFeedbackQuestion_CurriculumContentArea] FOREIGN KEY([ContentAreaCode])
REFERENCES [eWeb].[CurriculumContentArea] ([ContentAreaCode])
GO
ALTER TABLE [eWeb].[CurriculumFeedbackQuestion] CHECK CONSTRAINT [fk_CurriculumFeedbackQuestion_CurriculumContentArea]
GO
ALTER TABLE [eWeb].[CurriculumFeedbackQuestion]  WITH CHECK ADD  CONSTRAINT [fk_CurriculumFeedbackQuestion_CurriculumFeedbackQuestionType] FOREIGN KEY([QuestionTypeCode])
REFERENCES [eWeb].[CurriculumFeedbackQuestionType] ([QuestionTypeCode])
GO
ALTER TABLE [eWeb].[CurriculumFeedbackQuestion] CHECK CONSTRAINT [fk_CurriculumFeedbackQuestion_CurriculumFeedbackQuestionType]
GO
