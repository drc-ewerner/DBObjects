USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormParts]    Script Date: 7/2/2024 9:12:04 AM ******/
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
 CONSTRAINT [pk_TestFormParts] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[FormPart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormParts]  WITH CHECK ADD  CONSTRAINT [fk_TestFormParts_TestForms] FOREIGN KEY([AdministrationID], [Test], [Level], [Form])
REFERENCES [Scoring].[TestForms] ([AdministrationID], [Test], [Level], [Form])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormParts] CHECK CONSTRAINT [fk_TestFormParts_TestForms]
GO
ALTER TABLE [Scoring].[TestFormParts]  WITH CHECK ADD  CONSTRAINT [fk_TestFormParts_TestForms_2] FOREIGN KEY([AdministrationID], [Test], [Level], [FormPart])
REFERENCES [Scoring].[TestForms] ([AdministrationID], [Test], [Level], [Form])
GO
ALTER TABLE [Scoring].[TestFormParts] CHECK CONSTRAINT [fk_TestFormParts_TestForms_2]
GO
