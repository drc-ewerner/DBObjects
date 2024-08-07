USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[CATScaleScoreAdjustments]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[CATScaleScoreAdjustments](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Grade] [varchar](2) NOT NULL,
	[CATPath] [varchar](50) NOT NULL,
	[RawScore] [decimal](10, 5) NOT NULL,
	[PrelimScaleScore] [decimal](10, 5) NOT NULL,
	[FinalScaleScore] [decimal](10, 5) NULL,
	[PerformanceLevel] [varchar](20) NULL,
	[Form] [varchar](20) NULL,
	[SEM] [decimal](10, 5) NULL,
	[PrelimAbility] [decimal](10, 5) NOT NULL,
	[FinalAbility] [decimal](10, 5) NULL,
 CONSTRAINT [pk_CATScaleScoreAdjustments] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Grade] ASC,
	[CATPath] ASC,
	[PrelimScaleScore] ASC,
	[PrelimAbility] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[CATScaleScoreAdjustments] ADD  DEFAULT ((0.0)) FOR [PrelimAbility]
GO
