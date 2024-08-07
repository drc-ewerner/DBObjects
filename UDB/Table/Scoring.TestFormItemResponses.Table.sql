USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormItemResponses]    Script Date: 7/2/2024 9:12:04 AM ******/
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
 CONSTRAINT [pk_TestFormItemResponses] PRIMARY KEY CLUSTERED 
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
ALTER TABLE [Scoring].[TestFormItemResponses]  WITH CHECK ADD  CONSTRAINT [fk_TestFormItemResponses_ItemDetails] FOREIGN KEY([AdministrationID], [Test], [ItemID], [DetailID])
REFERENCES [Scoring].[ItemDetails] ([AdministrationID], [Test], [ItemID], [DetailID])
GO
ALTER TABLE [Scoring].[TestFormItemResponses] CHECK CONSTRAINT [fk_TestFormItemResponses_ItemDetails]
GO
ALTER TABLE [Scoring].[TestFormItemResponses]  WITH CHECK ADD  CONSTRAINT [fk_TestFormItemResponses_TestFormItems] FOREIGN KEY([AdministrationID], [Test], [Level], [Form], [ItemID])
REFERENCES [Scoring].[TestFormItems] ([AdministrationID], [Test], [Level], [Form], [ItemID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormItemResponses] CHECK CONSTRAINT [fk_TestFormItemResponses_TestFormItems]
GO
