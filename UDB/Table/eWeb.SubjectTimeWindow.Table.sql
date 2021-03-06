USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[SubjectTimeWindow]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[SubjectTimeWindow](
	[SubjectTimeWindowId] [int] IDENTITY(1,1) NOT NULL,
	[TimeWindowId] [int] NOT NULL,
	[ShortSubjectName] [nvarchar](10) NULL,
	[LongSubjectName] [nvarchar](50) NULL,
	[SubjectOrder] [smallint] NOT NULL,
	[SubjectCode] [varchar](3) NULL,
 CONSTRAINT [PK_SubjectTimeWindow_1] PRIMARY KEY CLUSTERED 
(
	[SubjectTimeWindowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[SubjectTimeWindow]  WITH CHECK ADD  CONSTRAINT [FK_SubjectTimeWindow_TimeWindow] FOREIGN KEY([TimeWindowId])
REFERENCES [eWeb].[TimeWindow] ([TimeWindowId])
GO
ALTER TABLE [eWeb].[SubjectTimeWindow] CHECK CONSTRAINT [FK_SubjectTimeWindow_TimeWindow]
GO
