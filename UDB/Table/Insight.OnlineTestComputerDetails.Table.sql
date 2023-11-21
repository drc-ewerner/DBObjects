USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[OnlineTestComputerDetails]    Script Date: 11/21/2023 8:51:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[OnlineTestComputerDetails](
	[AdministrationID] [int] NOT NULL,
	[OnlineTestID] [int] NOT NULL,
	[ComputerDetails] [nvarchar](max) NOT NULL,
 CONSTRAINT [pk_OnlineTestComputerDetails] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[OnlineTestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[OnlineTestComputerDetails]  WITH CHECK ADD  CONSTRAINT [fk_OnlineTestComputerDetails_OnlineTests] FOREIGN KEY([AdministrationID], [OnlineTestID])
REFERENCES [Insight].[OnlineTests] ([AdministrationID], [OnlineTestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[OnlineTestComputerDetails] CHECK CONSTRAINT [fk_OnlineTestComputerDetails_OnlineTests]
GO
