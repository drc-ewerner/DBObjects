USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestSession].[Extensions]    Script Date: 11/21/2023 8:51:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestSession].[Extensions](
	[AdministrationID] [int] NOT NULL,
	[TestSessionID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](1000) NULL,
 CONSTRAINT [pk_Extensions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestSessionID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [TestSession].[Extensions]  WITH CHECK ADD  CONSTRAINT [fk_Extensions_Core_TestSession] FOREIGN KEY([AdministrationID], [TestSessionID])
REFERENCES [Core].[TestSession] ([AdministrationID], [TestSessionID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestSession].[Extensions] CHECK CONSTRAINT [fk_Extensions_Core_TestSession]
GO
