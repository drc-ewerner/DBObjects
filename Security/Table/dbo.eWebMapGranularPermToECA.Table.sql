USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebMapGranularPermToECA]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebMapGranularPermToECA](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ScreenCode] [varchar](100) NOT NULL,
	[PermissionGranularECA] [varchar](255) NULL,
	[IsUI] [bit] NULL,
	[EffectiveDate] [datetime] NULL,
	[IsPathInFront] [bit] NULL,
	[IsAlsoClientless] [bit] NULL,
	[IsAdminAgnostic] [bit] NULL,
	[AlsoAddRole] [bit] NOT NULL,
	[IncludeProgramName] [bit] NULL,
 CONSTRAINT [PK__eWebMapGranularPermToECA] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eWebMapGranularPermToECA] ADD  DEFAULT ((0)) FOR [IsUI]
GO
ALTER TABLE [dbo].[eWebMapGranularPermToECA] ADD  CONSTRAINT [DF_eWebMapGranularPermToECA_IsPathInFront]  DEFAULT ((1)) FOR [IsPathInFront]
GO
ALTER TABLE [dbo].[eWebMapGranularPermToECA] ADD  CONSTRAINT [DF_eWebMapGranularPermToECA_IsAlsoClientless]  DEFAULT ((0)) FOR [IsAlsoClientless]
GO
ALTER TABLE [dbo].[eWebMapGranularPermToECA] ADD  CONSTRAINT [DF_eWebMapGranularPermToECA_IsAdminAgnostic]  DEFAULT ((0)) FOR [IsAdminAgnostic]
GO
ALTER TABLE [dbo].[eWebMapGranularPermToECA] ADD  CONSTRAINT [AlsoAddRole_def]  DEFAULT ((0)) FOR [AlsoAddRole]
GO
ALTER TABLE [dbo].[eWebMapGranularPermToECA] ADD  DEFAULT ((0)) FOR [IncludeProgramName]
GO
ALTER TABLE [dbo].[eWebMapGranularPermToECA]  WITH CHECK ADD  CONSTRAINT [fk_eWebMapGranularPermToECA_ScreenCode] FOREIGN KEY([ScreenCode])
REFERENCES [dbo].[eWebScreen] ([ScreenCode])
GO
ALTER TABLE [dbo].[eWebMapGranularPermToECA] CHECK CONSTRAINT [fk_eWebMapGranularPermToECA_ScreenCode]
GO
