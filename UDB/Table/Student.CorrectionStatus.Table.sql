USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[CorrectionStatus]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student].[CorrectionStatus](
	[AdministrationID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[Status] [varchar](20) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_CorrectionStatus] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Student].[CorrectionStatus] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Student].[CorrectionStatus]  WITH CHECK ADD  CONSTRAINT [fk_CorrectionStatus_Core_Student] FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Student].[CorrectionStatus] CHECK CONSTRAINT [fk_CorrectionStatus_Core_Student]
GO
