USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormParts]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormParts](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[FormPart] [varchar](20) NOT NULL,
	[PartName] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[FormPart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormParts]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [Level], [Form])
REFERENCES [Scoring].[TestForms] ([AdministrationID], [Test], [Level], [Form])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormParts]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [Level], [FormPart])
REFERENCES [Scoring].[TestForms] ([AdministrationID], [Test], [Level], [Form])
GO
