USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[CurriculumEligibleContent]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[CurriculumEligibleContent](
	[CurriculumID] [int] NOT NULL,
	[EligibleContentID] [varchar](20) NOT NULL,
 CONSTRAINT [pk_CurriculumEligibleContent] PRIMARY KEY CLUSTERED 
(
	[CurriculumID] ASC,
	[EligibleContentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[CurriculumEligibleContent]  WITH CHECK ADD  CONSTRAINT [fk_CurriculumEligibleContent_Curriculum] FOREIGN KEY([CurriculumID])
REFERENCES [eWeb].[Curriculum] ([CurriculumID])
ON DELETE CASCADE
GO
ALTER TABLE [eWeb].[CurriculumEligibleContent] CHECK CONSTRAINT [fk_CurriculumEligibleContent_Curriculum]
GO
