USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentOrderQuestionAnswer]    Script Date: 7/2/2024 9:12:03 AM ******/
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
 CONSTRAINT [pk_EnrollmentOrderQuestionAnswer] PRIMARY KEY CLUSTERED 
(
	[OrderQuestionAnswerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[EnrollmentOrderQuestionAnswer] ADD  DEFAULT (getdate()) FOR [LastUpdateDate]
GO
ALTER TABLE [eWeb].[EnrollmentOrderQuestionAnswer]  WITH CHECK ADD  CONSTRAINT [fk_EnrollmentOrderQuestionAnswer_EnrollmentOrder] FOREIGN KEY([OrderID])
REFERENCES [eWeb].[EnrollmentOrder] ([OrderID])
GO
ALTER TABLE [eWeb].[EnrollmentOrderQuestionAnswer] CHECK CONSTRAINT [fk_EnrollmentOrderQuestionAnswer_EnrollmentOrder]
GO
ALTER TABLE [eWeb].[EnrollmentOrderQuestionAnswer]  WITH CHECK ADD  CONSTRAINT [fk_EnrollmentOrderQuestionAnswer_EnrollmentQuestion] FOREIGN KEY([QuestionID])
REFERENCES [eWeb].[EnrollmentQuestion] ([QuestionID])
GO
ALTER TABLE [eWeb].[EnrollmentOrderQuestionAnswer] CHECK CONSTRAINT [fk_EnrollmentOrderQuestionAnswer_EnrollmentQuestion]
GO
