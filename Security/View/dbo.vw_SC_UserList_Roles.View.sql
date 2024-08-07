USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[vw_SC_UserList_Roles]    Script Date: 7/2/2024 9:45:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_SC_UserList_Roles]
AS
SELECT     CASE WHEN CHARINDEX(' of school', dbo.aspnet_Roles.RoleName) <> 0 THEN SUBSTRING(dbo.aspnet_Roles.RoleName, 1, CHARINDEX(' of school', 
                      dbo.aspnet_Roles.RoleName)) WHEN CHARINDEX(' of district', dbo.aspnet_Roles.RoleName) <> 0 THEN SUBSTRING(dbo.aspnet_Roles.RoleName, 1, 
                      CHARINDEX(' of district', dbo.aspnet_Roles.RoleName)) WHEN CHARINDEX(' of admin', dbo.aspnet_Roles.RoleName) 
                      <> 0 THEN SUBSTRING(dbo.aspnet_Roles.RoleName, 1, CHARINDEX(' of admin', dbo.aspnet_Roles.RoleName)) END AS userRole, 
                      dbo.aspnet_Membership.UserId
FROM         dbo.aspnet_Membership INNER JOIN
                      dbo.aspnet_Users ON dbo.aspnet_Membership.UserId = dbo.aspnet_Users.UserId INNER JOIN
                      dbo.aspnet_UsersInRoles ON dbo.aspnet_Users.UserId = dbo.aspnet_UsersInRoles.UserId INNER JOIN
                      dbo.aspnet_Roles ON dbo.aspnet_UsersInRoles.RoleId = dbo.aspnet_Roles.RoleId
WHERE     (CHARINDEX(' of school/', dbo.aspnet_Roles.RoleName) <> 0) OR
                      (CHARINDEX(' of district/', dbo.aspnet_Roles.RoleName) <> 0) OR
                      (CHARINDEX(' of admin/', dbo.aspnet_Roles.RoleName) <> 0)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[24] 4[38] 2[23] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "aspnet_Membership"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 329
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "aspnet_Users"
            Begin Extent = 
               Top = 6
               Left = 367
               Bottom = 114
               Right = 537
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "aspnet_UsersInRoles"
            Begin Extent = 
               Top = 6
               Left = 575
               Bottom = 84
               Right = 726
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "aspnet_Roles"
            Begin Extent = 
               Top = 84
               Left = 575
               Bottom = 192
               Right = 744
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
    ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_SC_UserList_Roles'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'     Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_SC_UserList_Roles'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_SC_UserList_Roles'
GO
