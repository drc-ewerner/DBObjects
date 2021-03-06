USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[ItemResponseDetails]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[ItemResponseDetails](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[DetailID] [varchar](50) NOT NULL,
	[DetailPosition] [int] NOT NULL,
	[ParentDetailID] [varchar](50) NOT NULL,
	[ItemPartType] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[ItemID] ASC,
	[DetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[ItemResponseDetails]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [ItemID])
REFERENCES [Scoring].[Items] ([AdministrationID], [Test], [ItemID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
