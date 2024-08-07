USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[LCS_Simulation]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[LCS_Simulation](
	[AdministrationID] [int] NOT NULL,
	[HistoricalID] [int] NOT NULL,
	[SimulationID] [int] NOT NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[LCSID] [varchar](50) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_LCS_Simulation] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[HistoricalID] ASC,
	[SimulationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Insight].[LCS_Simulation] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
