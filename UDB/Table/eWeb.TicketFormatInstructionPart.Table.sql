USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[TicketFormatInstructionPart]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[TicketFormatInstructionPart](
	[TicketFormatInstructionPartGuid] [uniqueidentifier] NOT NULL,
	[TicketFormatInstructionGuid] [uniqueidentifier] NOT NULL,
	[Title] [varchar](200) NOT NULL,
	[TitleBold] [bit] NOT NULL,
	[TitleUnderlined] [bit] NOT NULL,
	[TextOrdered] [bit] NOT NULL,
	[OrderId] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TicketFormatInstructionPartGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[TicketFormatInstructionPart] ADD  DEFAULT ((0)) FOR [TitleBold]
GO
ALTER TABLE [eWeb].[TicketFormatInstructionPart] ADD  DEFAULT ((0)) FOR [TitleUnderlined]
GO
ALTER TABLE [eWeb].[TicketFormatInstructionPart] ADD  DEFAULT ((0)) FOR [TextOrdered]
GO
ALTER TABLE [eWeb].[TicketFormatInstructionPart]  WITH CHECK ADD  CONSTRAINT [fk_TicketFormatInstructionPart_TicketFormatInstruction] FOREIGN KEY([TicketFormatInstructionGuid])
REFERENCES [eWeb].[TicketFormatInstruction] ([TicketFormatInstructionGuid])
GO
ALTER TABLE [eWeb].[TicketFormatInstructionPart] CHECK CONSTRAINT [fk_TicketFormatInstructionPart_TicketFormatInstruction]
GO
