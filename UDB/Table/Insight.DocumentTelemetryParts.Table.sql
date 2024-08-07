USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[DocumentTelemetryParts]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[DocumentTelemetryParts](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[Timestamp] [bigint] NOT NULL,
	[Telemetry] [nvarchar](max) NOT NULL,
	[Receives] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_DocumentTelemetryParts] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[DocumentTelemetryParts] ADD  DEFAULT ((1)) FOR [Receives]
GO
ALTER TABLE [Insight].[DocumentTelemetryParts] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Insight].[DocumentTelemetryParts] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
