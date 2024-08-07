USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[Attributions]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student].[Attributions](
	[AdministrationID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[DistrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
	[TestEventID] [int] NOT NULL,
	[AttributionDate] [datetime] NOT NULL,
	[UserEmail] [varchar](256) NULL,
	[UserID] [uniqueidentifier] NULL,
	[UserNotes] [varchar](max) NULL,
 CONSTRAINT [pk_Attributions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC,
	[DistrictCode] ASC,
	[SchoolCode] ASC,
	[TestEventID] ASC,
	[AttributionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Student].[Attributions] ADD  DEFAULT ((0)) FOR [TestEventID]
GO
ALTER TABLE [Student].[Attributions] ADD  DEFAULT (getdate()) FOR [AttributionDate]
GO
ALTER TABLE [Student].[Attributions]  WITH CHECK ADD  CONSTRAINT [fk_Attributions_Core_Student] FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Student].[Attributions] CHECK CONSTRAINT [fk_Attributions_Core_Student]
GO
