USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[Extensions]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[Extensions](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](1000) NULL,
 CONSTRAINT [pk_Extensions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Document].[Extensions]  WITH CHECK ADD  CONSTRAINT [fk_Extensions_Core_Document] FOREIGN KEY([AdministrationID], [DocumentID])
REFERENCES [Core].[Document] ([AdministrationID], [DocumentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Document].[Extensions] CHECK CONSTRAINT [fk_Extensions_Core_Document]
GO
