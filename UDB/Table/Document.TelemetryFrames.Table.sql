USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[TelemetryFrames]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[TelemetryFrames](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[Sequence] [smallint] NOT NULL,
	[Frame] [smallint] NOT NULL,
	[FrameType] [varchar](20) NOT NULL,
	[FrameID] [varchar](20) NOT NULL,
	[StartOffset] [int] NOT NULL,
	[Duration] [int] NULL,
	[EntryResponse] [varchar](10) NULL,
	[ExitResponse] [varchar](10) NULL,
	[FrameDetail] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[Sequence] ASC,
	[Frame] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Document].[TelemetryFrames]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [DocumentID], [Sequence])
REFERENCES [Document].[TelemetrySequences] ([AdministrationID], [DocumentID], [Sequence])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
