USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[Extensions]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student].[Extensions](
	[AdministrationID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](1000) NULL,
 CONSTRAINT [pk_Extensions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC,
	[Category] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Student].[Extensions]  WITH CHECK ADD  CONSTRAINT [fk_Extensions_Core_Student] FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Student].[Extensions] CHECK CONSTRAINT [fk_Extensions_Core_Student]
GO
