USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[TelemetrySequences]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[TelemetrySequences](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[Sequence] [smallint] NOT NULL,
	[EntryTime] [datetime] NOT NULL,
	[ExitType] [varchar](20) NOT NULL,
	[ExitOffset] [int] NULL,
	[SubmitOffset] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[Sequence] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Document].[TelemetrySequences]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [DocumentID])
REFERENCES [Core].[Document] ([AdministrationID], [DocumentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
