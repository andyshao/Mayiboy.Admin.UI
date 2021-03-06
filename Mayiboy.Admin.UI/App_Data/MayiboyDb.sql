USE [MayiboyDb]
GO
/****** Object:  StoredProcedure [dbo].[proc_PermissionByUserId_select]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	根据用户Id查询用户权限
*/

CREATE PROCEDURE [dbo].[proc_PermissionByUserId_select]
@UserId int
AS
BEGIN
	--1、查询用户所属权限

	--2、查询用户所属角色权限
	WITH userrolep AS (
	SELECT p.* FROM UserRoleJoin urj 
		LEFT JOIN dbo.RolePermissionsJoin rpj ON urj.RoleId=rpj.RoleId 
		LEFT JOIN dbo.Permissions p ON rpj.PermissionsId=p.Id
	WHERE urj.IsValid=1 AND rpj.IsValid=1 AND p.IsValid=1 and urj.UserId=@UserId
	)

	--3、查询用户拒绝权限[待开发延伸]
	
	SELECT DISTINCT * FROM userrolep
END

GO
/****** Object:  StoredProcedure [dbo].[proc_SystemDepartmentById_select]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_SystemDepartmentById_select]
@Id int
AS
BEGIN

WITH t AS
	(
		SELECT * FROM dbo.Department WITH(NOLOCK) WHERE Id=@Id AND IsValid=1
		UNION ALL
		SELECT a.* FROM dbo.Department AS a WITH(NOLOCK) INNER JOIN t AS b ON a.Pid=b.Id AND a.IsValid=1
	)

	SELECT DISTINCT * from t ORDER BY t.Id
END

GO
/****** Object:  StoredProcedure [dbo].[proc_SystemMenuById_select]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_SystemMenuById_select]
@Id int
AS
BEGIN
 WITH t AS
	(
		SELECT * FROM dbo.SystemMenu WITH(NOLOCK) WHERE Id=@Id AND IsValid=1
		UNION ALL
		SELECT a.* FROM dbo.SystemMenu AS a WITH(NOLOCK) INNER JOIN t AS b ON a.Pid=b.Id AND a.IsValid=1
	)

	SELECT DISTINCT * from t ORDER BY t.Sort
END

GO
/****** Object:  StoredProcedure [dbo].[proc_SystemMenuByNavbarId_select]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
查询栏目所有菜单
*/

CREATE PROCEDURE [dbo].[proc_SystemMenuByNavbarId_select] 
	-- Add the parameters for the stored procedure here
@NavbarId int
AS
BEGIN
	 WITH t AS
	(
		SELECT * FROM dbo.SystemMenu WITH(NOLOCK) WHERE NavbarId=@NavbarId AND IsValid=1
		UNION ALL
		SELECT a.* FROM dbo.SystemMenu AS a WITH(NOLOCK) INNER JOIN t AS b ON a.Pid=b.Id AND a.IsValid=1
	)

	SELECT DISTINCT * from t ORDER BY t.Sort
END

GO
/****** Object:  StoredProcedure [dbo].[proc_SystemMenuByUserIdandNavbarId_select]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

/*查询用户 栏目所有系统菜单
*/
CREATE PROCEDURE [dbo].[proc_SystemMenuByUserIdandNavbarId_select]
	@NavbarId INT,
	@UserId INT
AS
BEGIN

		WITH sysmenu AS (
				SELECT sm.* FROM UserRoleJoin urj 
					LEFT JOIN dbo.UserRole ur ON urj.RoleId=ur.Id
					LEFT JOIN dbo.RolePermissionsJoin rpj ON ur.Id=rpj.RoleId
					LEFT JOIN dbo.Permissions p ON rpj.PermissionsId=p.Id 
					LEFT JOIN dbo.SystemMenu sm ON p.MenuId=sm.Id
				WHERE urj.IsValid=1 
					AND ur.IsValid=1 
					AND rpj.IsValid=1 
					AND p.IsValid=1 
					AND sm.IsValid=1 
					AND p.IsValid=1 
					AND urj.UserId=@UserId AND sm.NavbarId=@NavbarId
		), tb AS(
			SELECT DISTINCT * FROM sysmenu
		), t AS
		(
			select * from tb WITH(nolock) where Id IN (SELECT Id FROM tb)
			union all
			select a.* from SystemMenu AS a WITH(nolock) inner join t AS b on a.Id=b.Pid WHERE a.Pid =0
		)
 
		SELECT DISTINCT * from t
END

GO
/****** Object:  StoredProcedure [dbo].[proc_SystemNavbarByUserId_select]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

/*查询用户栏目
*/
CREATE PROCEDURE [dbo].[proc_SystemNavbarByUserId_select]
@UserId	 int
AS
BEGIN

	WITH sysnavbar AS
	 (
		SELECT sn.* FROM dbo.SystemNavbar sn 
			LEFT JOIN dbo.SystemMenu sm ON sn.Id=sm.NavbarId
			LEFT JOIN dbo.Permissions p ON sm.Id=p.MenuId
			LEFT JOIN dbo.RolePermissionsJoin rpj ON p.Id=rpj.PermissionsId
			LEFT JOIN dbo.UserRole ur ON rpj.RoleId=ur.Id
			LEFT JOIN dbo.UserRoleJoin urj ON ur.Id=urj.RoleId
			LEFT JOIN dbo.UserInfo ui ON urj.UserId=ui.Id
		WHERE ui.IsValid=1 
			AND urj.IsValid=1 
			AND ur.IsValid=1 
			AND rpj.IsValid=1 
			AND p.IsValid=1 
			AND  sm.IsValid=1 
			AND sn.IsValid=1 
			AND ui.Id=@UserId
		)


		SELECT DISTINCT * FROM sysnavbar
END

GO
/****** Object:  Table [dbo].[AppIdAuth]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AppIdAuth](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AppId] [varchar](50) NOT NULL,
	[AuthToken] [varchar](50) NOT NULL,
	[Status] [int] NOT NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[Remark] [varchar](500) NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_AppIdAuth] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[City]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[City](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Pid] [int] NOT NULL,
	[CityName] [varchar](50) NOT NULL,
	[ZipCode] [varchar](50) NULL,
	[Remark] [varchar](500) NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_City] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Department]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Department](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Pid] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[Remark] [varchar](500) NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Permissions]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Permissions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MenuId] [int] NULL,
	[Name] [varchar](50) NULL,
	[Action] [varchar](500) NULL,
	[Code] [varchar](50) NULL,
	[Type] [int] NOT NULL,
	[Remark] [varchar](500) NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_Permissions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RolePermissionsJoin]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RolePermissionsJoin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NavbarId] [int] NOT NULL,
	[MenuId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[PermissionsId] [int] NOT NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_RolePermissionsJoin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SystemAppSettings]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SystemAppSettings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](500) NULL,
	[KeyWord] [varchar](100) NOT NULL,
	[KeyValue] [varchar](1024) NULL,
	[Remark] [varchar](500) NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_SystemAppSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SystemMenu]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SystemMenu](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Pid] [int] NULL,
	[NavbarId] [int] NULL,
	[Name] [varchar](50) NULL,
	[UrlAddress] [varchar](500) NULL,
	[MenuType] [int] NOT NULL,
	[Icon] [varchar](50) NULL,
	[Sort] [int] NOT NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[Remark] [varchar](500) NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_SystemMenu] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SystemNavbar]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SystemNavbar](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Url] [varchar](500) NULL,
	[Remark] [varchar](500) NULL,
	[Sort] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[CreateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[UpdateUserId] [int] NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_SystemNavbar] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SystemOperationLog]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SystemOperationLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Content] [varchar](1024) NULL,
	[Type] [int] NOT NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_SystemOperationLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserDepartmentJoin]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserDepartmentJoin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[DepartmentId] [int] NOT NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_UserDepartmentJoin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserInfo]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LoginName] [varchar](200) NOT NULL,
	[Password] [varchar](200) NOT NULL,
	[Email] [varchar](500) NULL,
	[Name] [varchar](50) NULL,
	[HeadimgUrl] [varchar](500) NULL,
	[Sex] [int] NULL,
	[Mobile] [varchar](50) NULL,
	[HomeAddress] [varchar](500) NULL,
	[CreateUserId] [int] NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NOT NULL,
	[Remark] [varchar](500) NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_UserInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserRole](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Remark] [varchar](500) NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserRoleJoin]    Script Date: 2018/5/29 8:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoleJoin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
	[IsValid] [int] NOT NULL,
 CONSTRAINT [PK_UserRoleJoin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[AppIdAuth] ON 

INSERT [dbo].[AppIdAuth] ([Id], [AppId], [AuthToken], [Status], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (1, N'000001', N'2efd0f58295249b0846be6f45b8afaa3', 1, 8, CAST(0x0000A8EF005B4562 AS DateTime), 1, CAST(0x0000A8EF00847D3D AS DateTime), N'', 1)
INSERT [dbo].[AppIdAuth] ([Id], [AppId], [AuthToken], [Status], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (4, N'000002', N'77599f9bb85445289dda2186804342b6', 1, 1, CAST(0x0000A8EF006CE483 AS DateTime), 1, CAST(0x0000A8EF007EA193 AS DateTime), N'asdf', 1)
SET IDENTITY_INSERT [dbo].[AppIdAuth] OFF
SET IDENTITY_INSERT [dbo].[Department] ON 

INSERT [dbo].[Department] ([Id], [Pid], [Name], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (1, 0, N'技术部', N'技术部', 1, CAST(0x0000A8D200B15035 AS DateTime), 1, CAST(0x0000A8D200B15035 AS DateTime), 1)
INSERT [dbo].[Department] ([Id], [Pid], [Name], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (2, 1, N'官网活动', N'处理公司官网业务', 1, CAST(0x0000A8D200B15035 AS DateTime), 1, CAST(0x0000A8D200B15035 AS DateTime), 1)
INSERT [dbo].[Department] ([Id], [Pid], [Name], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (3, 1, N'物流', N'物流信息', 1, CAST(0x0000A8D200B15035 AS DateTime), 1, CAST(0x0000A8D200B15035 AS DateTime), 1)
INSERT [dbo].[Department] ([Id], [Pid], [Name], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (4, 0, N'销售部', N'销售部', 1, CAST(0x0000A8D200B15035 AS DateTime), 1, CAST(0x0000A8D200B15035 AS DateTime), 1)
INSERT [dbo].[Department] ([Id], [Pid], [Name], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (5, 0, N'客服部', N'客服部', 1, CAST(0x0000A8D200B15035 AS DateTime), 1, CAST(0x0000A8D200B15035 AS DateTime), 1)
INSERT [dbo].[Department] ([Id], [Pid], [Name], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (6, 0, N'财务部', N'财务部', 1, CAST(0x0000A8D200B15035 AS DateTime), 1, CAST(0x0000A8D200B15035 AS DateTime), 1)
INSERT [dbo].[Department] ([Id], [Pid], [Name], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (7, 0, N'人事部', N'人事部', 1, CAST(0x0000A8D200B15035 AS DateTime), 1, CAST(0x0000A8D2012BE272 AS DateTime), 1)
INSERT [dbo].[Department] ([Id], [Pid], [Name], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (8, 0, N'法务部', N'法务部', 1, CAST(0x0000A8D200B15035 AS DateTime), 1, CAST(0x0000A8D2012BDEBC AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[Department] OFF
SET IDENTITY_INSERT [dbo].[Permissions] ON 

INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (5, 13, N'保存栏目', N'SysNavbar/Save', N'P1805025216', 0, N'编辑栏目', 1, CAST(0x0000A8D401242302 AS DateTime), 1, CAST(0x0000A8D80074E772 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (6, 13, N'删除栏目', N'SysNavbar/Del', N'P1805025243', 0, N'删除栏目删除栏目删除栏目删除栏目', 1, CAST(0x0000A8D401244225 AS DateTime), 1, CAST(0x0000A8D7011C3028 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (19, 13, N'查询栏目', N'SysNavbar/Query', N'P1805060347', 0, N'查询栏目', 1, CAST(0x0000A8D800747C48 AS DateTime), 1, CAST(0x0000A8D800747C48 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (20, 14, N'查询菜单', N'SysMenu/Query', N'P1805060505', 0, NULL, 1, CAST(0x0000A8D80074C43C AS DateTime), 1, CAST(0x0000A8D80074C43C AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (21, 14, N'保存菜单', N'SysMenu/Save', N'P1805060614', 0, NULL, 1, CAST(0x0000A8D8007513A4 AS DateTime), 1, CAST(0x0000A8D8007513A4 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (22, 14, N'删除系统菜单', N'SysMenu/Del', N'P1805060637', 0, NULL, 1, CAST(0x0000A8D800752E8B AS DateTime), 1, CAST(0x0000A8D800752E8B AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (23, 14, N'保存菜单权限', N'SysMenu/SaveMenuPermissions', N'P1805060727', 0, NULL, 1, CAST(0x0000A8D8007573DB AS DateTime), 1, CAST(0x0000A8D8007573DB AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (24, 14, N'删除菜单权限', N'SysMenu/DelPermissions', N'P1805060745', 0, NULL, 1, CAST(0x0000A8D800759764 AS DateTime), 1, CAST(0x0000A8D800759764 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (25, 16, N'查询角色', N'UserRole/Query', N'P1805060854', 0, NULL, 1, CAST(0x0000A8D80075D148 AS DateTime), 1, CAST(0x0000A8D80075E024 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (26, 16, N'保存用户角色', N'UserRole/Save', N'P1805060937', 0, NULL, 1, CAST(0x0000A8D80076011F AS DateTime), 1, CAST(0x0000A8D80076011F AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (27, 16, N'删除用户角色', N'UserRole/Del', N'P1805061007', 0, NULL, 1, CAST(0x0000A8D80076252B AS DateTime), 1, CAST(0x0000A8D80076252B AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (28, 16, N'保存角色权限', N'UserRole/SaveRolePermissions', N'P1805061028', 0, NULL, 1, CAST(0x0000A8D800763C74 AS DateTime), 1, CAST(0x0000A8D800763C74 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (29, 17, N'页面权限', N'UserInfo/Index', N'P1805061120', 0, NULL, 1, CAST(0x0000A8D800767B99 AS DateTime), 1, CAST(0x0000A8D800767B99 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (30, 17, N'用户信息查询', N'UserInfo/Query', N'P1805061136', 0, NULL, 1, CAST(0x0000A8D800768C40 AS DateTime), 1, CAST(0x0000A8D800768C40 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (31, 17, N'保存用户信息查询', N'UserInfo/Save', N'P1805061201', 0, NULL, 1, CAST(0x0000A8D80076AD7B AS DateTime), 1, CAST(0x0000A8D80076AD7B AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (32, 17, N'保存用户角色', N'UserInfo/SaveUserRole', N'P1805061223', 0, NULL, 1, CAST(0x0000A8D80076C364 AS DateTime), 1, CAST(0x0000A8D80076C364 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (33, 17, N'删除用户', N'UserInfo/Del', N'P1805061253', 0, NULL, 1, CAST(0x0000A8D80076E6A2 AS DateTime), 1, CAST(0x0000A8D80076E6A2 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (34, 22, N'部门页面显示', N'Department/Index', N'P1805061323', 0, NULL, 1, CAST(0x0000A8D800770B1F AS DateTime), 1, CAST(0x0000A8D800770B1F AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (35, 22, N'查询部门', N'Department/Query', N'P1805061352', 0, NULL, 1, CAST(0x0000A8D800772B97 AS DateTime), 1, CAST(0x0000A8D80077705C AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (36, 22, N'保存部门', N'Department/Save', N'P1805061416', 0, NULL, 1, CAST(0x0000A8D80077486A AS DateTime), 1, CAST(0x0000A8D80077486A AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (37, 22, N'删除部门', N'Department/Del', N'P1805061505', 0, NULL, 1, CAST(0x0000A8D800778D6F AS DateTime), 1, CAST(0x0000A8D800778D6F AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (38, 11, N'查询微信公众号', N'WeiXin/Index', N'P1805061204', 0, NULL, 1, CAST(0x0000A8D80087397A AS DateTime), 1, CAST(0x0000A8D80087397A AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (39, 9, N'部门', NULL, N'P1805100608', 0, NULL, 1, CAST(0x0000A8DC00A67D50 AS DateTime), 1, CAST(0x0000A8DC00A67D50 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (40, 5, N'系统操作日志页面', N'SysLog/Index', N'P1805133556', 0, N'系统操作日志页面', 1, CAST(0x0000A8DF01220742 AS DateTime), 1, CAST(0x0000A8DF012A2E32 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (41, 5, N'系统操作日志查询', N'SysLog/Query', N'P1805130622', 0, N'系统操作日志查询', 1, CAST(0x0000A8DF012A666E AS DateTime), 1, CAST(0x0000A8DF012A666E AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (42, 4, N'通用字典页面', N'SysDict/Index', N'P1805130856', 0, NULL, 1, CAST(0x0000A8DF012AFFA8 AS DateTime), 1, CAST(0x0000A8DF012B18FE AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (43, 4, N'通用字典页面查询', N'SysDict/Query', N'P1805130914', 0, NULL, 1, CAST(0x0000A8DF012B34BF AS DateTime), 1, CAST(0x0000A8DF012B34BF AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (44, 4, N'系统字典删除', N'SysDict/Del', N'P1805130939', 0, NULL, 1, CAST(0x0000A8DF012B4A0E AS DateTime), 1, CAST(0x0000A8DF012B4A0E AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (45, 4, N'系统字典保存', N'SysDict/Save', N'P1805130956', 0, N'系统字典保存', 1, CAST(0x0000A8DF012B605A AS DateTime), 1, CAST(0x0000A8DF012B605A AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (46, 17, N'重置密码', N'UserInfo/ResetPassword', N'P1805164219', 0, N'重置用户默认密码', 1, CAST(0x0000A8E2008F8079 AS DateTime), 1, CAST(0x0000A8E2008F8079 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (47, 1023, N'应用授权页面', N'AppIdAuth/Index', N'P1805271154', 0, N'应用授权页面', 1, CAST(0x0000A8ED016DD5F8 AS DateTime), 1, CAST(0x0000A8ED016DD5F8 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (48, 1023, N'应用授权保存', N'AppIdAuth/Save', N'P1805271226', 0, N'应用授权保存', 1, CAST(0x0000A8ED016E0216 AS DateTime), 1, CAST(0x0000A8ED016E0216 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (49, 1023, N'删除应用授权', N'AppIdAuth/Del', N'P1805271303', 0, N'删除应用授权', 1, CAST(0x0000A8ED016E1F77 AS DateTime), 1, CAST(0x0000A8ED016E2512 AS DateTime), 1)
INSERT [dbo].[Permissions] ([Id], [MenuId], [Name], [Action], [Code], [Type], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (50, 1023, N'更新应用授权状态', N'AppIdAuth/UpdateStatus', N'P1805271345', 0, N'应用授权状态', 1, CAST(0x0000A8ED016E6D46 AS DateTime), 1, CAST(0x0000A8ED016E6D46 AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[Permissions] OFF
SET IDENTITY_INSERT [dbo].[RolePermissionsJoin] ON 

INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (6, 2, 13, 2, 6, 1, CAST(0x0000A8D701421799 AS DateTime), 1, CAST(0x0000A8D701421799 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (30, 2, 9, 2, 39, 1, CAST(0x0000A8DC00EF1FEC AS DateTime), 1, CAST(0x0000A8DC00EF1FEC AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (31, 2, 13, 2, 5, 1, CAST(0x0000A8DC00EF2BF2 AS DateTime), 1, CAST(0x0000A8DC00EF2BF2 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (32, 2, 13, 2, 19, 1, CAST(0x0000A8DC00EF2BF3 AS DateTime), 1, CAST(0x0000A8DC00EF2BF3 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (33, 2, 14, 2, 20, 1, CAST(0x0000A8DC00EF3012 AS DateTime), 1, CAST(0x0000A8DC00EF3012 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (34, 2, 14, 2, 21, 1, CAST(0x0000A8DC00EF3012 AS DateTime), 1, CAST(0x0000A8DC00EF3012 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (35, 2, 14, 2, 22, 1, CAST(0x0000A8DC00EF3013 AS DateTime), 1, CAST(0x0000A8DC00EF3013 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (36, 2, 14, 2, 23, 1, CAST(0x0000A8DC00EF3013 AS DateTime), 1, CAST(0x0000A8DC00EF3013 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (37, 2, 14, 2, 24, 1, CAST(0x0000A8DC00EF3013 AS DateTime), 1, CAST(0x0000A8DC00EF3013 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (38, 2, 16, 2, 25, 1, CAST(0x0000A8DC00EF32D2 AS DateTime), 1, CAST(0x0000A8DC00EF32D2 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (39, 2, 16, 2, 26, 1, CAST(0x0000A8DC00EF32D3 AS DateTime), 1, CAST(0x0000A8DC00EF32D3 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (40, 2, 16, 2, 27, 1, CAST(0x0000A8DC00EF32D3 AS DateTime), 1, CAST(0x0000A8DC00EF32D3 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (41, 2, 16, 2, 28, 1, CAST(0x0000A8DC00EF32D3 AS DateTime), 1, CAST(0x0000A8DC00EF32D3 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (42, 2, 17, 2, 29, 1, CAST(0x0000A8DC00EF3590 AS DateTime), 1, CAST(0x0000A8DC00EF3590 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (43, 2, 17, 2, 30, 1, CAST(0x0000A8DC00EF3590 AS DateTime), 1, CAST(0x0000A8DC00EF3590 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (44, 2, 17, 2, 31, 1, CAST(0x0000A8DC00EF3591 AS DateTime), 1, CAST(0x0000A8DC00EF3591 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (45, 2, 17, 2, 32, 1, CAST(0x0000A8DC00EF3591 AS DateTime), 1, CAST(0x0000A8DC00EF3591 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (46, 2, 17, 2, 33, 1, CAST(0x0000A8DC00EF3591 AS DateTime), 1, CAST(0x0000A8DC00EF3591 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (47, 2, 22, 2, 34, 1, CAST(0x0000A8DC00EF3897 AS DateTime), 1, CAST(0x0000A8DC00EF3897 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (48, 2, 22, 2, 35, 1, CAST(0x0000A8DC00EF3897 AS DateTime), 1, CAST(0x0000A8DC00EF3897 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (49, 2, 22, 2, 36, 1, CAST(0x0000A8DC00EF3897 AS DateTime), 1, CAST(0x0000A8DC00EF3897 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (50, 2, 22, 2, 37, 1, CAST(0x0000A8DC00EF3897 AS DateTime), 1, CAST(0x0000A8DC00EF3897 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (51, 2, 5, 1002, 40, 1, CAST(0x0000A8DF01222966 AS DateTime), 1, CAST(0x0000A8DF01222966 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (52, 2, 5, 2, 40, 1, CAST(0x0000A8DF012A81AA AS DateTime), 1, CAST(0x0000A8DF012A81AA AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (53, 2, 5, 2, 41, 1, CAST(0x0000A8DF012A81AC AS DateTime), 1, CAST(0x0000A8DF012A81AC AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (54, 2, 4, 2, 42, 1, CAST(0x0000A8DF012C0E33 AS DateTime), 1, CAST(0x0000A8DF012C0E33 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (55, 2, 4, 2, 43, 1, CAST(0x0000A8DF012C0E34 AS DateTime), 1, CAST(0x0000A8DF012C0E34 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (56, 2, 4, 2, 44, 1, CAST(0x0000A8DF012C0E34 AS DateTime), 1, CAST(0x0000A8DF012C0E34 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (57, 2, 4, 2, 45, 1, CAST(0x0000A8DF012C0E34 AS DateTime), 1, CAST(0x0000A8DF012C0E34 AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (59, 2, 17, 2, 46, 1, CAST(0x0000A8E2008F8EEB AS DateTime), 1, CAST(0x0000A8E2008F8EEB AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (60, 2, 5, 1002, 41, 1, CAST(0x0000A8E20091449E AS DateTime), 1, CAST(0x0000A8E20091449E AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (61, 2, 1023, 2, 47, 1, CAST(0x0000A8ED016E78FA AS DateTime), 1, CAST(0x0000A8ED016E78FA AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (62, 2, 1023, 2, 48, 1, CAST(0x0000A8ED016E78FB AS DateTime), 1, CAST(0x0000A8ED016E78FB AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (63, 2, 1023, 2, 49, 1, CAST(0x0000A8ED016E78FB AS DateTime), 1, CAST(0x0000A8ED016E78FB AS DateTime), 1)
INSERT [dbo].[RolePermissionsJoin] ([Id], [NavbarId], [MenuId], [RoleId], [PermissionsId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (64, 2, 1023, 2, 50, 1, CAST(0x0000A8ED016E78FC AS DateTime), 1, CAST(0x0000A8ED016E78FC AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[RolePermissionsJoin] OFF
SET IDENTITY_INSERT [dbo].[SystemAppSettings] ON 

INSERT [dbo].[SystemAppSettings] ([Id], [Name], [KeyWord], [KeyValue], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (2, N'默认密码', N'SystemDefaultPassword', N'123456', N'添加用户默认密码', 0, CAST(0x0000A8CC0011664C AS DateTime), 1, CAST(0x0000A8E000EA4B50 AS DateTime), 1)
INSERT [dbo].[SystemAppSettings] ([Id], [Name], [KeyWord], [KeyValue], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (4, N'默认头像', N'SystemDefaultHeadimg', N'Content/Images/defaultimg.jpg', N'添加系统用户默认头像', 0, CAST(0x0000A8CC0011664C AS DateTime), 1, CAST(0x0000A8E000EA674D AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[SystemAppSettings] OFF
SET IDENTITY_INSERT [dbo].[SystemMenu] ON 

INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (2, 0, 2, N'系统管理', NULL, 0, N'fa fa-desktop', 1, 0, CAST(0x0000A8C6017DA056 AS DateTime), 0, CAST(0x0000A8C6017DA056 AS DateTime), N'系统菜单', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (3, 0, 2, N'单位组织', NULL, 1, N'fa fa-navicon', 1, 0, CAST(0x0000A8C6017DA056 AS DateTime), 1, CAST(0x0000A8EF006860AB AS DateTime), N'单位组织', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (4, 2, 2, N'通用字典', N'SystemManage/SysDict/Index', 0, N'fa fa-navicon', 5, 0, CAST(0x0000A8C6017DA056 AS DateTime), 1, CAST(0x0000A8D2016D6E5C AS DateTime), N'通用字典', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (5, 2, 2, N'系统操作日志', N'SystemManage/SysLog/Index', 0, N'fa fa-navicon', 4, 0, CAST(0x0000A8C6017DA056 AS DateTime), 1, CAST(0x0000A8DF0129FD72 AS DateTime), N'系统操作日志', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (6, 2, 2, N'数据管理', NULL, 0, N'fa fa-navicon', 3, 0, CAST(0x0000A8C6017DA056 AS DateTime), 1, CAST(0x0000A8D500ED878F AS DateTime), N'数据管理', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (7, 6, 2, N'数据库备份', NULL, 0, N'fa fa-navicon', 1, 0, CAST(0x0000A8C6017DA056 AS DateTime), 1, CAST(0x0000A8D500ED8BC3 AS DateTime), N'数据库备份', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (8, 6, 2, N'数据表管理', N'', 0, N'fa fa-navicon', 1, 0, CAST(0x0000A8C6017DA056 AS DateTime), 0, CAST(0x0000A8C6017DA056 AS DateTime), N'数据表管理', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (10, 0, 3, N'基础管理', N'', 0, N'fa fa-navicon', 1, 0, CAST(0x0000A8C601838468 AS DateTime), 0, CAST(0x0000A8C601838468 AS DateTime), N'基础管理', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (11, 10, 3, N'公众号管理', N'Weixin/Index', 0, N'fa fa-navicon', 1, 0, CAST(0x0000A8C601838468 AS DateTime), 1, CAST(0x0000A8D80087BFB0 AS DateTime), N'公众号管理', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (13, 2, 2, N'栏目管理', N'SystemManage/SysNavbar/Index', 0, N'fa fa-navicon', 1, 0, CAST(0x0000A8C80014B46E AS DateTime), 0, CAST(0x0000A8C80014B46E AS DateTime), N'栏目管理', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (14, 2, 2, N'菜单管理', N'SystemManage/SysMenu/Index', 0, N'fa fa-navicon', 2, 0, CAST(0x0000A8C80014B46E AS DateTime), 0, CAST(0x0000A8C80014B46E AS DateTime), N'菜单管理', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (16, 2, 2, N'角色管理', N'SystemManage/UserRole/Index', 0, N'fa fa-navicon', 2, 0, CAST(0x0000A8C9012FE0D5 AS DateTime), 0, CAST(0x0000A8C9012FE0D5 AS DateTime), N'角色管理', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (17, 2, 2, N'用户管理', N'SystemManage/UserInfo/Index', 0, N'fa fa-navicon', 2, 0, CAST(0x0000A8C9012FE0D5 AS DateTime), 0, CAST(0x0000A8C9012FE0D5 AS DateTime), N'用户管理', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (22, 2, 2, N'部门管理', N'SystemManage/Department/Index', 0, N'fa fa-navicon', 2, 0, CAST(0x0000A8C9012FE0D5 AS DateTime), 0, CAST(0x0000A8C9012FE0D5 AS DateTime), N'部门管理', 1)
INSERT [dbo].[SystemMenu] ([Id], [Pid], [NavbarId], [Name], [UrlAddress], [MenuType], [Icon], [Sort], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (1023, 2, 2, N'应用授权管理', N'SystemManage/AppIdAuth/Index', 0, N'fa fa-navicon', 5, 1, CAST(0x0000A8ED016D3CEC AS DateTime), 1, CAST(0x0000A8ED016D9239 AS DateTime), N'主要是编辑后台接口调用着授权Token', 1)
SET IDENTITY_INSERT [dbo].[SystemMenu] OFF
SET IDENTITY_INSERT [dbo].[SystemNavbar] ON 

INSERT [dbo].[SystemNavbar] ([Id], [Name], [Url], [Remark], [Sort], [CreateTime], [CreateUserId], [UpdateTime], [UpdateUserId], [IsValid]) VALUES (2, N'系统配置', N'', N'主要配置用户基本信息、权限，常量配置', 1, CAST(0x0000A8C50171B30D AS DateTime), NULL, CAST(0x0000A8E001040AC8 AS DateTime), 1, 1)
INSERT [dbo].[SystemNavbar] ([Id], [Name], [Url], [Remark], [Sort], [CreateTime], [CreateUserId], [UpdateTime], [UpdateUserId], [IsValid]) VALUES (3, N'微信平台', NULL, N'微信相关', 2, CAST(0x0000A8C50171B30D AS DateTime), NULL, CAST(0x0000A8CA003D76D7 AS DateTime), NULL, 1)
SET IDENTITY_INSERT [dbo].[SystemNavbar] OFF
SET IDENTITY_INSERT [dbo].[SystemOperationLog] ON 

INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (1, N'系统操作日志', 1, 1, CAST(0x0000A8E000F4EC27 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (2, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E00100D6D8 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (3, N'[LoginName:未知:::1]-[Name:未知:::1]-[Content:登录]', 0, 0, CAST(0x0000A8E00100E0CD AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (4, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统栏目]', 0, 1, CAST(0x0000A8E001040ABE AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (5, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统角色]', 0, 1, CAST(0x0000A8E001042845 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (6, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E0010436CF AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (7, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E001044655 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (8, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8E0010BCE7B AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (9, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E0010BE1D5 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (10, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8E001122D0F AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (11, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E001196888 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (12, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E001198F55 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (13, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E00119DBD3 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (14, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8E0011B0108 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (15, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E0015739CC AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (16, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8E101305B78 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (17, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8E101320395 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (18, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E1016042B5 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (19, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E1016051BD AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (20, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8E2008ED39D AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (21, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单操作权限]', 0, 1, CAST(0x0000A8E2008F8076 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (22, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统角色权限]', 0, 1, CAST(0x0000A8E2008F8EE8 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (23, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E2008F919A AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (24, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E2008F9B20 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (25, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:重置用户密码]', 0, 1, CAST(0x0000A8E2008FA435 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (26, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:重置用户密码]', 0, 1, CAST(0x0000A8E2008FED75 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (27, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E20090D572 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (28, N'[LoginName:simon]-[Name:闲僧]-[Content:用户登录]', 0, 0, CAST(0x0000A8E20090E645 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (29, N'[LoginName:simon]-[Name:闲僧]-[Content:注销登录]', 0, 8, CAST(0x0000A8E20090FB50 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (30, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E200910E29 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (31, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统角色权限]', 0, 1, CAST(0x0000A8E200911DFD AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (32, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统角色权限]', 0, 1, CAST(0x0000A8E2009121F1 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (33, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统角色权限]', 0, 1, CAST(0x0000A8E200912676 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (34, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统角色权限]', 0, 1, CAST(0x0000A8E200912ADF AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (35, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统角色权限]', 0, 1, CAST(0x0000A8E200912E8C AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (36, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统角色权限]', 0, 1, CAST(0x0000A8E20091449D AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (37, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:重置用户密码]', 0, 1, CAST(0x0000A8E200928BCB AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (38, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:重置用户密码]', 0, 1, CAST(0x0000A8E20092900B AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (39, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:重置用户密码]', 0, 1, CAST(0x0000A8E2009295C2 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (40, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:重置用户密码]', 0, 1, CAST(0x0000A8E20096C219 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (41, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:重置用户密码]', 0, 1, CAST(0x0000A8E20096C9F5 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (42, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E20096DC5B AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (43, N'[LoginName:simon]-[Name:闲僧]-[Content:用户登录]', 0, 0, CAST(0x0000A8E20096E701 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (44, N'[LoginName:simon]-[Name:闲僧]-[Content:注销登录]', 0, 8, CAST(0x0000A8E20096EFE5 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (45, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E20096F99A AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (46, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E2009E1C0D AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (47, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E2009E71CC AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (48, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:修改用户密码]', 0, 1, CAST(0x0000A8E200A479C7 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (49, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:修改用户密码]', 0, 1, CAST(0x0000A8E200A4A972 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (50, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:修改用户密码]', 0, 1, CAST(0x0000A8E200A4B4E4 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (51, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:修改用户密码]', 0, 1, CAST(0x0000A8E200A4BDAF AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (52, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:修改用户密码]', 0, 1, CAST(0x0000A8E200A52BE5 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (53, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E200A52F26 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (54, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E200A542E0 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (55, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:修改用户密码]', 0, 1, CAST(0x0000A8E200A54AFC AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (56, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E200A58A0F AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (57, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E200A5937E AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (58, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E20116D170 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (59, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E20116DEB8 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (60, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8E2011AADE7 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (61, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8E2016F4455 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (62, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E201841B61 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (63, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E201848A30 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (64, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E20184A428 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (65, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E201856B3C AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (66, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E2018581C5 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (67, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E300119C0C AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (68, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E3001359EE AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (69, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E300135FC9 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (70, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E300136924 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (71, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E300147F77 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (72, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E300194B25 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (73, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E300196CB0 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (74, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E30019D78F AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (75, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E3001BE9E4 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (76, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统用户信息]', 0, 1, CAST(0x0000A8E3001BF34A AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (77, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:注销登录]', 0, 1, CAST(0x0000A8E3002404AB AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (78, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8E3002417CB AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (79, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8E501266182 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (80, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8E900FFFDF3 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (81, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8EA0164CD1E AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (82, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8EA01657020 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (83, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8ED001EBA12 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (84, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8ED010ACA50 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (85, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8ED0147F878 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (86, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 0, CAST(0x0000A8ED016D0C9C AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (87, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单]', 0, 1, CAST(0x0000A8ED016D3CEA AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (88, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单]', 0, 1, CAST(0x0000A8ED016D4F33 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (89, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单]', 0, 1, CAST(0x0000A8ED016D9239 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (90, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单操作权限]', 0, 1, CAST(0x0000A8ED016DD5F6 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (91, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单操作权限]', 0, 1, CAST(0x0000A8ED016E0216 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (92, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单操作权限]', 0, 1, CAST(0x0000A8ED016E1F76 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (93, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单操作权限]', 0, 1, CAST(0x0000A8ED016E2511 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (94, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单操作权限]', 0, 1, CAST(0x0000A8ED016E6D46 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (95, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统角色权限]', 0, 1, CAST(0x0000A8ED016E78F8 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (96, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8EF005A7B31 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (97, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8EF005ADB0E AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (98, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8EF005DE7FC AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (99, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:删除应用授权配置]', 0, 1, CAST(0x0000A8EF005E7B14 AS DateTime), 1)
GO
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (100, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单]', 0, 1, CAST(0x0000A8EF0068471A AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (101, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单]', 0, 1, CAST(0x0000A8EF0068553B AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (102, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单]', 0, 1, CAST(0x0000A8EF00685945 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (103, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存系统菜单]', 0, 1, CAST(0x0000A8EF006860AB AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (104, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF0069577F AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (105, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF00695BC3 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (106, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF00697BA3 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (107, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF00698212 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (108, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:删除应用授权配置]', 0, 1, CAST(0x0000A8EF0069848C AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (109, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF006CB0F8 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (110, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF006CBF1E AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (111, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:删除应用授权配置]', 0, 1, CAST(0x0000A8EF006CD52B AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (112, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF006CDF44 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (113, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF006CE482 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (114, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF006CED32 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (115, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF006F3A4D AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (116, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF0072D62E AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (117, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF007448AC AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (118, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF007465FC AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (119, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF00746E5C AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (120, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF00752547 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (121, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF007C66E8 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (122, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:删除应用授权配置]', 0, 1, CAST(0x0000A8EF007C6DAA AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (123, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:保存应用授权配置]', 0, 1, CAST(0x0000A8EF007D03C4 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (124, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007D0E5F AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (125, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007D1359 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (126, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007D5274 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (127, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007D5372 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (128, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007D5423 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (129, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007D54D6 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (130, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007D5594 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (131, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E23BE AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (132, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E33FC AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (133, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E445A AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (134, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E5351 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (135, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E55AB AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (136, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E5792 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (137, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E61E6 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (138, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E6367 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (139, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E6D58 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (140, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E6E89 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (141, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E6F5D AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (142, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E7CEE AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (143, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E7E6D AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (144, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E7FC3 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (145, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E8E5E AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (146, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E8F98 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (147, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E9061 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (148, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E9BB2 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (149, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E9DBC AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (150, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007E9FD3 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (151, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007EA192 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (152, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F477A AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (153, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F4826 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (154, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F48CF AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (155, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F492B AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (156, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F4968 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (157, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F49A1 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (158, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F49D9 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (159, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F4A13 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (160, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F4BDB AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (161, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F4DC1 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (162, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F5910 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (163, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F5BB9 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (164, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF007F6290 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (165, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8EF008475B4 AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (166, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:更新应用标识状态]', 0, 1, CAST(0x0000A8EF00847D3C AS DateTime), 1)
INSERT [dbo].[SystemOperationLog] ([Id], [Content], [Type], [CreateUserId], [CreateTime], [IsValid]) VALUES (167, N'[LoginName:admin]-[Name:蚂蚁男孩]-[Content:用户登录]', 0, 1, CAST(0x0000A8EF00850410 AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[SystemOperationLog] OFF
SET IDENTITY_INSERT [dbo].[UserDepartmentJoin] ON 

INSERT [dbo].[UserDepartmentJoin] ([Id], [UserId], [DepartmentId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (8, 8, 1, 1, CAST(0x0000A8E3001BF34B AS DateTime), 1, CAST(0x0000A8E3001BF34B AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[UserDepartmentJoin] OFF
SET IDENTITY_INSERT [dbo].[UserInfo] ON 

INSERT [dbo].[UserInfo] ([Id], [LoginName], [Password], [Email], [Name], [HeadimgUrl], [Sex], [Mobile], [HomeAddress], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (1, N'admin', N'E10ADC3949BA59ABBE56E057F20F883E', N'system@mayiboy.com', N'蚂蚁男孩', N'Content/Images/headimg.png', 1, N'***********', N'*****', 0, CAST(0x0000A8C10021CD26 AS DateTime), 1, CAST(0x0000A8E300147F82 AS DateTime), N'超级管理员', 1)
INSERT [dbo].[UserInfo] ([Id], [LoginName], [Password], [Email], [Name], [HeadimgUrl], [Sex], [Mobile], [HomeAddress], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [Remark], [IsValid]) VALUES (8, N'simon', N'E10ADC3949BA59ABBE56E057F20F883E', N'caimeng2009@126.com', N'闲僧', N'Content/Images/defaultimg.jpg', 1, N'098765432123', NULL, 1, CAST(0x0000A8D500A67AB6 AS DateTime), 1, CAST(0x0000A8E3001BF34B AS DateTime), NULL, 1)
SET IDENTITY_INSERT [dbo].[UserInfo] OFF
SET IDENTITY_INSERT [dbo].[UserRole] ON 

INSERT [dbo].[UserRole] ([Id], [Name], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (2, N'管理员', N'管理员', 1, CAST(0x0000A8CF00576B3D AS DateTime), 1, CAST(0x0000A8CF00576B3E AS DateTime), 1)
INSERT [dbo].[UserRole] ([Id], [Name], [Remark], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (1002, N'技术部', N'管理后台配置', 1, CAST(0x0000A8D401239D52 AS DateTime), 1, CAST(0x0000A8E00104284A AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[UserRole] OFF
SET IDENTITY_INSERT [dbo].[UserRoleJoin] ON 

INSERT [dbo].[UserRoleJoin] ([Id], [UserId], [RoleId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (3, 1, 2, 1, CAST(0x0000A8D500E0683D AS DateTime), 1, CAST(0x0000A8D500E0683D AS DateTime), 1)
INSERT [dbo].[UserRoleJoin] ([Id], [UserId], [RoleId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (4, 1, 1002, 1, CAST(0x0000A8D500E09002 AS DateTime), 1, CAST(0x0000A8D500E09002 AS DateTime), 1)
INSERT [dbo].[UserRoleJoin] ([Id], [UserId], [RoleId], [CreateUserId], [CreateTime], [UpdateUserId], [UpdateTime], [IsValid]) VALUES (5, 8, 1002, 1, CAST(0x0000A8D80073BF5E AS DateTime), 1, CAST(0x0000A8D80073BF5E AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[UserRoleJoin] OFF
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'应用标识' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth', @level2type=N'COLUMN',@level2name=N'AppId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授权Token' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth', @level2type=N'COLUMN',@level2name=N'AuthToken'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否启用状态（0：未启用；1：已启用）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效（0：无效；1：有效）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'应用授权' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AppIdAuth'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'父级Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'City', @level2type=N'COLUMN',@level2name=N'Pid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'城市名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'City', @level2type=N'COLUMN',@level2name=N'CityName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'邮政编码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'City', @level2type=N'COLUMN',@level2name=N'ZipCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'City', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'City', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'City', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'City', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'City', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'父级主键Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'Pid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部门名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注说明' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建人Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改用户id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效（0：无效；1：有效）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部门信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'菜单Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'MenuId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'操作地址（控制器/操作）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'Action'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'权限代码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'类型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注说明' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新用户id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permissions', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RolePermissionsJoin', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'栏目id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RolePermissionsJoin', @level2type=N'COLUMN',@level2name=N'NavbarId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'菜单Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RolePermissionsJoin', @level2type=N'COLUMN',@level2name=N'MenuId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RolePermissionsJoin', @level2type=N'COLUMN',@level2name=N'RoleId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'权限Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RolePermissionsJoin', @level2type=N'COLUMN',@level2name=N'PermissionsId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RolePermissionsJoin', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RolePermissionsJoin', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RolePermissionsJoin', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RolePermissionsJoin', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效（0：无效；1：有效）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RolePermissionsJoin', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系统配置名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'键' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings', @level2type=N'COLUMN',@level2name=N'KeyWord'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'值' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings', @level2type=N'COLUMN',@level2name=N'KeyValue'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改用户' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效（0：无效；1：有效）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'字典配置' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemAppSettings'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'父级Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'Pid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'导航id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'NavbarId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'菜单名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Url地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'UrlAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'菜单类型(0：内部；1：外部)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'MenuType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'图标' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'Icon'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排序' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'Sort'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建人Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改人id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注说明' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效（0：无效；1：有效）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系统菜单' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemMenu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemNavbar', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'导航名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemNavbar', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'导航地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemNavbar', @level2type=N'COLUMN',@level2name=N'Url'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注说明' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemNavbar', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemNavbar', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemNavbar', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemNavbar', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemNavbar', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效（0：无效；1：有效）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemNavbar', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'导航栏' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemNavbar'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemOperationLog', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'操作内容说明' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemOperationLog', @level2type=N'COLUMN',@level2name=N'Content'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'类型（1:登录；2：退出；3：其他操作）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemOperationLog', @level2type=N'COLUMN',@level2name=N'Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemOperationLog', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemOperationLog', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效（0：无效；1：有效）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemOperationLog', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系统操作日志' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemOperationLog'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserDepartmentJoin', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserDepartmentJoin', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部门Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserDepartmentJoin', @level2type=N'COLUMN',@level2name=N'DepartmentId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserDepartmentJoin', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserDepartmentJoin', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserDepartmentJoin', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserDepartmentJoin', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效标识（1：有效；0：无效）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserDepartmentJoin', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户部门关联' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserDepartmentJoin'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户信息主键id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'登录名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'LoginName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'密码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'Password'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'邮箱地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'姓名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'密文手机号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'Mobile'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'家庭地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'HomeAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改用户id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效（0：无效；1：有效）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户角色主键Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注说明' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改用户id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效（0：无效;1：有效）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRole', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRoleJoin', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRoleJoin', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRoleJoin', @level2type=N'COLUMN',@level2name=N'RoleId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRoleJoin', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRoleJoin', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRoleJoin', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRoleJoin', @level2type=N'COLUMN',@level2name=N'UpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效(1:有效；0：无效)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserRoleJoin', @level2type=N'COLUMN',@level2name=N'IsValid'
GO
USE [master]
GO
ALTER DATABASE [MayiboyDb] SET  READ_WRITE 
GO
