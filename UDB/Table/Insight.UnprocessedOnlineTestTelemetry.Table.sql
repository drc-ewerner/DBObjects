USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[UnprocessedOnlineTestTelemetry]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[UnprocessedOnlineTestTelemetry](
	[AdministrationID] [int] NOT NULL,
	[UnprocessedOnlineTestID] [int] NOT NULL,
	[Telemetry] [nvarchar](max) NOT NULL,
 CONSTRAINT [pk_UnprocessedOnlineTestTelemetry] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[UnprocessedOnlineTestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[UnprocessedOnlineTestTelemetry]  WITH CHECK ADD  CONSTRAINT [fk_UnprocessedOnlineTestTelemetry_UnprocessedOnlineTests] FOREIGN KEY([AdministrationID], [UnprocessedOnlineTestID])
REFERENCES [Insight].[UnprocessedOnlineTests] ([AdministrationID], [UnprocessedOnlineTestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[UnprocessedOnlineTestTelemetry] CHECK CONSTRAINT [fk_UnprocessedOnlineTestTelemetry_UnprocessedOnlineTests]
GO
