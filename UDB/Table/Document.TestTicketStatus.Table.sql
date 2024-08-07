USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[TestTicketStatus]    Script Date: 7/2/2024 9:12:03 AM ******/
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
 CONSTRAINT [pk_TestTicketStatus] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[StatusTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Document].[TestTicketStatus] ADD  DEFAULT (getdate()) FOR [StatusTime]
GO
ALTER TABLE [Document].[TestTicketStatus]  WITH CHECK ADD  CONSTRAINT [fk_TestTicketStatus_TestTicket] FOREIGN KEY([AdministrationID], [DocumentID])
REFERENCES [Document].[TestTicket] ([AdministrationID], [DocumentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Document].[TestTicketStatus] CHECK CONSTRAINT [fk_TestTicketStatus_TestTicket]
GO
