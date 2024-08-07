USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestSessionTicketParts]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestSessionTicketParts](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[PartName] [varchar](50) NOT NULL,
	[PartTest] [varchar](50) NULL,
	[PartLevel] [varchar](50) NULL,
	[ModuleOrder] [int] NULL,
 CONSTRAINT [pk_TestSessionTicketParts] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[PartName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestSessionTicketParts]  WITH CHECK ADD  CONSTRAINT [fk_TestSessionTicketParts_TestLevels] FOREIGN KEY([AdministrationID], [Test], [Level])
REFERENCES [Scoring].[TestLevels] ([AdministrationID], [Test], [Level])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestSessionTicketParts] CHECK CONSTRAINT [fk_TestSessionTicketParts_TestLevels]
GO
