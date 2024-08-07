USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[MultiModuleTicketParts]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[MultiModuleTicketParts](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[PartTest] [varchar](50) NOT NULL,
	[PartLevel] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[FormPart] [varchar](20) NOT NULL,
	[PartName] [varchar](50) NULL,
	[ModuleOrder] [int] NULL,
 CONSTRAINT [pk_MultiModuleTicketParts] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[PartTest] ASC,
	[PartLevel] ASC,
	[Form] ASC,
	[FormPart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
