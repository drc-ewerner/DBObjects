USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentOrderQuestionAnswer]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[EnrollmentOrderQuestionAnswer](
	[OrderQuestionAnswerID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[QuestionID] [int] NOT NULL,
	[Answer] [varchar](500) NOT NULL,
	[LastUpdateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EnrollmentOrderQuestionAnswer] PRIMARY KEY CLUSTERED 
(
	[OrderQuestionAnswerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[EnrollmentOrderQuestionAnswer] ADD  DEFAULT (getdate()) FOR [LastUpdateDate]
GO
ALTER TABLE [eWeb].[EnrollmentOrderQuestionAnswer]  WITH CHECK ADD  CONSTRAINT [FK_EnrollmentOrderQuestionAnswer_EnrollmentCustomizedQuestions] FOREIGN KEY([QuestionID])
REFERENCES [eWeb].[EnrollmentQuestion] ([QuestionID])
GO
ALTER TABLE [eWeb].[EnrollmentOrderQuestionAnswer] CHECK CONSTRAINT [FK_EnrollmentOrderQuestionAnswer_EnrollmentCustomizedQuestions]
GO
ALTER TABLE [eWeb].[EnrollmentOrderQuestionAnswer]  WITH CHECK ADD  CONSTRAINT [FK_EnrollmentOrderQuestionAnswer_EnrollmentOrder] FOREIGN KEY([OrderID])
REFERENCES [eWeb].[EnrollmentOrder] ([OrderID])
GO
ALTER TABLE [eWeb].[EnrollmentOrderQuestionAnswer] CHECK CONSTRAINT [FK_EnrollmentOrderQuestionAnswer_EnrollmentOrder]
GO
