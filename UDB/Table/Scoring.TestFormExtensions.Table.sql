USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormExtensions]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormExtensions](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](100) NOT NULL,
 CONSTRAINT [pk_TestFormExtensions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormExtensions]  WITH CHECK ADD  CONSTRAINT [fk_TestFormExtensions_TestForms] FOREIGN KEY([AdministrationID], [Test], [Level], [Form])
REFERENCES [Scoring].[TestForms] ([AdministrationID], [Test], [Level], [Form])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormExtensions] CHECK CONSTRAINT [fk_TestFormExtensions_TestForms]
GO
