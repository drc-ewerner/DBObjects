USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[ItemDetailPsychometrics]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[ItemDetailPsychometrics](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[DetailID] [varchar](20) NOT NULL,
	[FromDetailID] [varchar](20) NOT NULL,
	[RawScore] [decimal](10, 5) NOT NULL,
	[ScaleScore] [decimal](10, 5) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[ItemID] ASC,
	[DetailID] ASC,
	[RawScore] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[ItemDetailPsychometrics] ADD  DEFAULT ((0)) FOR [RawScore]
GO
ALTER TABLE [Scoring].[ItemDetailPsychometrics]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [ItemID], [DetailID])
REFERENCES [Scoring].[ItemDetails] ([AdministrationID], [Test], [ItemID], [DetailID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
