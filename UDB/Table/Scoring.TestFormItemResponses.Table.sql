USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormItemResponses]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormItemResponses](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[DetailID] [varchar](20) NOT NULL,
	[CorrectResponse] [varchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[ItemID] ASC,
	[DetailID] ASC,
	[CorrectResponse] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormItemResponses]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [Level], [Form], [ItemID])
REFERENCES [Scoring].[TestFormItems] ([AdministrationID], [Test], [Level], [Form], [ItemID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormItemResponses]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [ItemID], [DetailID])
REFERENCES [Scoring].[ItemDetails] ([AdministrationID], [Test], [ItemID], [DetailID])
GO
