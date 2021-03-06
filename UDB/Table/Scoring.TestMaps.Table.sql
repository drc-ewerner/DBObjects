USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestMaps]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestMaps](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Map] [varchar](50) NOT NULL,
	[Description] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Map] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestMaps]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test])
REFERENCES [Scoring].[Tests] ([AdministrationID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
