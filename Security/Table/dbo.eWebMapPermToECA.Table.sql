USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebMapPermToECA]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebMapPermToECA](
	[ScreenCode] [varchar](100) NOT NULL,
	[PermissionTopNavECA] [varchar](100) NOT NULL,
 CONSTRAINT [PK_eWebMapPermToECA] PRIMARY KEY CLUSTERED 
(
	[ScreenCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
