USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[Schedule]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[Schedule](
	[AdministrationID] [int] NOT NULL,
	[Schedule] [varchar](20) NOT NULL,
	[RuleWeight] [int] NOT NULL,
	[Inclusion] [varchar](3) NOT NULL,
	[RuleType] [varchar](20) NOT NULL,
	[LowValue] [int] NOT NULL,
	[HighValue] [int] NOT NULL,
	[DistrictCode] [varchar](15) NULL,
	[SchoolCode] [varchar](15) NULL,
 CONSTRAINT [pk_Schedule] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Schedule] ASC,
	[RuleWeight] ASC,
	[Inclusion] ASC,
	[RuleType] ASC,
	[LowValue] ASC,
	[HighValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
