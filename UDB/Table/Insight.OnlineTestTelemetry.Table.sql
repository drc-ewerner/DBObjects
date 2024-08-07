USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[OnlineTestTelemetry]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[OnlineTestTelemetry](
	[AdministrationID] [int] NOT NULL,
	[OnlineTestID] [int] NOT NULL,
	[Telemetry] [nvarchar](max) NOT NULL,
 CONSTRAINT [pk_OnlineTestTelemetry] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[OnlineTestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[OnlineTestTelemetry]  WITH CHECK ADD  CONSTRAINT [fk_OnlineTestTelemetry_OnlineTests] FOREIGN KEY([AdministrationID], [OnlineTestID])
REFERENCES [Insight].[OnlineTests] ([AdministrationID], [OnlineTestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[OnlineTestTelemetry] CHECK CONSTRAINT [fk_OnlineTestTelemetry_OnlineTests]
GO
