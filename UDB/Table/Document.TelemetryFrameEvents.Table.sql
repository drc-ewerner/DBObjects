USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[TelemetryFrameEvents]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[TelemetryFrameEvents](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[Sequence] [smallint] NOT NULL,
	[Frame] [smallint] NOT NULL,
	[FrameEvent] [smallint] NOT NULL,
	[FrameOffset] [int] NOT NULL,
	[EventType] [varchar](20) NOT NULL,
	[EventInfo] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[Sequence] ASC,
	[Frame] ASC,
	[FrameEvent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Document].[TelemetryFrameEvents]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [DocumentID], [Sequence], [Frame])
REFERENCES [Document].[TelemetryFrames] ([AdministrationID], [DocumentID], [Sequence], [Frame])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
