USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[TelemetryFrameEvents]    Script Date: 7/2/2024 9:12:03 AM ******/
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
 CONSTRAINT [pk_TelemetryFrameEvents] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[Sequence] ASC,
	[Frame] ASC,
	[FrameEvent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Document].[TelemetryFrameEvents]  WITH CHECK ADD  CONSTRAINT [fk_TelemetryFrameEvents_TelemetryFrames] FOREIGN KEY([AdministrationID], [DocumentID], [Sequence], [Frame])
REFERENCES [Document].[TelemetryFrames] ([AdministrationID], [DocumentID], [Sequence], [Frame])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Document].[TelemetryFrameEvents] CHECK CONSTRAINT [fk_TelemetryFrameEvents_TelemetryFrames]
GO
