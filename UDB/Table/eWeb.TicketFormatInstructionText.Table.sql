USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[TicketFormatInstructionText]    Script Date: 11/21/2023 8:51:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[TicketFormatInstructionText](
	[TicketFormatInstructionTextGuid] [uniqueidentifier] NOT NULL,
	[TicketFormatInstructionPartGuid] [uniqueidentifier] NOT NULL,
	[InstructionText] [varchar](1000) NOT NULL,
	[OrderId] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TicketFormatInstructionTextGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[TicketFormatInstructionText]  WITH CHECK ADD  CONSTRAINT [fk_TicketFormatInstructionText] FOREIGN KEY([TicketFormatInstructionPartGuid])
REFERENCES [eWeb].[TicketFormatInstructionPart] ([TicketFormatInstructionPartGuid])
GO
ALTER TABLE [eWeb].[TicketFormatInstructionText] CHECK CONSTRAINT [fk_TicketFormatInstructionText]
GO
