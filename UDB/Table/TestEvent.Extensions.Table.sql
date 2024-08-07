USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestEvent].[Extensions]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestEvent].[Extensions](
	[AdministrationID] [int] NOT NULL,
	[TestEventID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](100) NULL,
 CONSTRAINT [pk_Extensions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestEventID] ASC,
	[Test] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [TestEvent].[Extensions]  WITH CHECK ADD  CONSTRAINT [fk_Extensions_Core_TestEvent] FOREIGN KEY([AdministrationID], [TestEventID], [Test])
REFERENCES [Core].[TestEvent] ([AdministrationID], [TestEventID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestEvent].[Extensions] CHECK CONSTRAINT [fk_Extensions_Core_TestEvent]
GO
