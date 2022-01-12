USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[TestTicket]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[TestTicket](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[Test] [varchar](50) NULL,
	[Level] [varchar](20) NULL,
	[Form] [varchar](20) NULL,
	[UserName] [varchar](50) NOT NULL,
	[Password] [varchar](20) NOT NULL,
	[Spiraled] [int] NULL,
	[NotTestedCode] [varchar](50) NULL,
	[PartName] [varchar](50) NULL,
	[ReportingCode] [varchar](20) NULL,
	[BaseDocumentID] [int] NULL,
	[ForceSubmitMarkDate] [datetime] NULL,
	[ModuleOrder] [int] NULL,
	[RegistrationID] [varchar](100) NULL,
	[ExternalFormID] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Document].[TestTicket]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [DocumentID])
REFERENCES [Core].[Document] ([AdministrationID], [DocumentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
