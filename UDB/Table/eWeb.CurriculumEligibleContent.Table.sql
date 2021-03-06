USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[CurriculumEligibleContent]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[CurriculumEligibleContent](
	[CurriculumID] [int] NOT NULL,
	[EligibleContentID] [varchar](20) NOT NULL,
 CONSTRAINT [PK_CurriculumEligibleContent] PRIMARY KEY CLUSTERED 
(
	[CurriculumID] ASC,
	[EligibleContentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[CurriculumEligibleContent]  WITH CHECK ADD  CONSTRAINT [FK_CurriculumEligibleContent_Curriculum] FOREIGN KEY([CurriculumID])
REFERENCES [eWeb].[Curriculum] ([CurriculumID])
ON DELETE CASCADE
GO
ALTER TABLE [eWeb].[CurriculumEligibleContent] CHECK CONSTRAINT [FK_CurriculumEligibleContent_Curriculum]
GO
