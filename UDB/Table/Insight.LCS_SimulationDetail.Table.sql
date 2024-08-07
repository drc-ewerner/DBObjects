USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[LCS_SimulationDetail]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[LCS_SimulationDetail](
	[AdministrationID] [int] NOT NULL,
	[HistoricalID] [int] NOT NULL,
	[SimulationID] [int] NOT NULL,
	[SimulationDetailID] [int] NOT NULL,
	[DistrictName] [varchar](100) NULL,
	[LCSID] [varchar](50) NULL,
	[LCSName] [varchar](250) NULL,
	[LCSDetails] [varchar](max) NULL,
	[LoadTestTime] [float] NULL,
	[TestSubmitTime] [float] NULL,
	[ContentImageSource] [varchar](40) NULL,
	[HostName] [varchar](100) NULL,
	[ClientName] [varchar](100) NULL,
	[CanonicalHostName] [varchar](100) NULL,
	[HostAddress] [varchar](100) NULL,
	[Addresses] [varchar](100) NULL,
	[ComputerDetails] [varchar](8000) NULL,
	[Registered] [varchar](100) NULL,
 CONSTRAINT [pk_LCS_SimulationDetail] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[HistoricalID] ASC,
	[SimulationID] ASC,
	[SimulationDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[LCS_SimulationDetail]  WITH CHECK ADD  CONSTRAINT [fk_LCS_SimulationDetail_LCS_Simulation] FOREIGN KEY([AdministrationID], [HistoricalID], [SimulationID])
REFERENCES [Insight].[LCS_Simulation] ([AdministrationID], [HistoricalID], [SimulationID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[LCS_SimulationDetail] CHECK CONSTRAINT [fk_LCS_SimulationDetail_LCS_Simulation]
GO
