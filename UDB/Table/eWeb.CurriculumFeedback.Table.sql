USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[CurriculumFeedback]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[CurriculumFeedback](
	[FeedbackID] [int] IDENTITY(1,1) NOT NULL,
	[SavedDate] [datetime] NOT NULL,
	[UserEmail] [varchar](100) NOT NULL,
	[DistrictCode] [varchar](10) NOT NULL,
	[SchoolCode] [varchar](10) NOT NULL,
	[ContentAreaCode] [varchar](10) NOT NULL,
	[GradeOrCourseCode] [varchar](50) NOT NULL,
	[UnitID] [varchar](10) NOT NULL,
	[LessonID] [varchar](14) NOT NULL,
	[QuestionResponse1] [char](1) NULL,
	[QuestionResponse2] [char](1) NULL,
	[QuestionResponse3] [char](1) NULL,
	[QuestionResponse4] [char](1) NULL,
	[QuestionResponse5] [char](1) NULL,
	[QuestionResponse6] [char](1) NULL,
	[QuestionResponse7] [char](1) NULL,
	[QuestionResponse8] [char](1) NULL,
	[QuestionResponse9] [char](1) NULL,
	[QuestionResponse10] [char](1) NULL,
	[QuestionResponse11] [char](1) NULL,
	[QuestionComment1] [varchar](1500) NULL,
	[QuestionComment2] [varchar](1500) NULL,
	[QuestionComment3] [varchar](1500) NULL,
	[QuestionComment4] [varchar](1500) NULL,
	[QuestionComment5] [varchar](1500) NULL,
	[QuestionComment6] [varchar](1500) NULL,
	[QuestionComment7] [varchar](1500) NULL,
	[QuestionComment8] [varchar](1500) NULL,
	[QuestionComment9] [varchar](1500) NULL,
	[QuestionComment10] [varchar](1500) NULL,
	[QuestionComment11] [varchar](1500) NULL,
	[AdditionalComment] [varchar](max) NULL,
	[PPID] [varchar](20) NULL,
	[DistrictType] [varchar](20) NULL,
	[YearsOfExperience] [varchar](20) NULL,
 CONSTRAINT [pk_CurriculumFeedback] PRIMARY KEY CLUSTERED 
(
	[FeedbackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [eWeb].[CurriculumFeedback]  WITH CHECK ADD  CONSTRAINT [fk_CurriculumFeedback_CurriculumContentArea] FOREIGN KEY([ContentAreaCode])
REFERENCES [eWeb].[CurriculumContentArea] ([ContentAreaCode])
GO
ALTER TABLE [eWeb].[CurriculumFeedback] CHECK CONSTRAINT [fk_CurriculumFeedback_CurriculumContentArea]
GO
