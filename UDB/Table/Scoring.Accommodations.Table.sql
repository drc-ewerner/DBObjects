USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[Accommodations]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[Accommodations](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Accommodation] [varchar](50) NOT NULL,
	[ScoringRule] [varchar](50) NOT NULL,
	[Priority] [int] NULL,
	[Adjustment] [decimal](10, 5) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Accommodation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[Accommodations]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test])
REFERENCES [Scoring].[Tests] ([AdministrationID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
