USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestMapExtensions]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestMapExtensions](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Map] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](100) NOT NULL,
 CONSTRAINT [pk_TestMapExtensions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Map] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestMapExtensions]  WITH CHECK ADD  CONSTRAINT [fk_TestMapExtensions_TestMaps] FOREIGN KEY([AdministrationID], [Test], [Map])
REFERENCES [Scoring].[TestMaps] ([AdministrationID], [Test], [Map])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestMapExtensions] CHECK CONSTRAINT [fk_TestMapExtensions_TestMaps]
GO
