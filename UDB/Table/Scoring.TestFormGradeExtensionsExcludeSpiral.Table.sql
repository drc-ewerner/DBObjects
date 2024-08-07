USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormGradeExtensionsExcludeSpiral]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormGradeExtensionsExcludeSpiral](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[Grade] [varchar](2) NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](100) NOT NULL,
 CONSTRAINT [pk_TestFormGradeExtensionsExcludeSpiral] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[Grade] ASC,
	[Category] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormGradeExtensionsExcludeSpiral] ADD  DEFAULT ('') FOR [Form]
GO
ALTER TABLE [Scoring].[TestFormGradeExtensionsExcludeSpiral] ADD  DEFAULT ('') FOR [Grade]
GO
ALTER TABLE [Scoring].[TestFormGradeExtensionsExcludeSpiral]  WITH CHECK ADD  CONSTRAINT [fk_TestFormGradeExtensionsExcludeSpiral_TestLevels] FOREIGN KEY([AdministrationID], [Test], [Level])
REFERENCES [Scoring].[TestLevels] ([AdministrationID], [Test], [Level])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormGradeExtensionsExcludeSpiral] CHECK CONSTRAINT [fk_TestFormGradeExtensionsExcludeSpiral_TestLevels]
GO
