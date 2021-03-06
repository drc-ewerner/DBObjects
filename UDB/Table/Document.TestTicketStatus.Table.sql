USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[TestTicketStatus]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[TestTicketStatus](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[StatusTime] [datetime] NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[LocalTimeOffset] [varchar](10) NULL,
	[Timezone] [varchar](5) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[StatusTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Document].[TestTicketStatus] ADD  DEFAULT (getdate()) FOR [StatusTime]
GO
ALTER TABLE [Document].[TestTicketStatus]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [DocumentID])
REFERENCES [Document].[TestTicket] ([AdministrationID], [DocumentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
