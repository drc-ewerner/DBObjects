USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestLevels]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestLevels](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Description] [varchar](1000) NULL,
	[OptionalProcessing] [varchar](30) NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [pk_TestLevels] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestLevels]  WITH CHECK ADD  CONSTRAINT [fk_TestLevels_Tests] FOREIGN KEY([AdministrationID], [Test])
REFERENCES [Scoring].[Tests] ([AdministrationID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestLevels] CHECK CONSTRAINT [fk_TestLevels_Tests]
GO
