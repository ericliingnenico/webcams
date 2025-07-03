Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spPDAGetMMD]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spPDAGetMMD]
GO

create proc spPDAGetMMD 
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/03/08 5:33p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetMMD.sql $-->
--<!--$$NoKeywords: $-->
as
--retrieve MMD data for caching at PDA
 
 SET NOCOUNT ON

 --get Survey version
 SELECT A = AttrValue
   FROM CAMS.dbo.tblControl
  WHERE Attribute = 'MMDVersion'

 --M_M_D
 SELECT 
	A = MMD_ID,
	B = ISNULL(Maker, ''),
	C = ISNULL(Model, ''),
	D = ISNULL(Device, ''),
	E = ISNULL(CASE WHEN SiteClientID IS NULL THEN ClientID ELSE SiteClientID END, '')
   FROM M_M_D m LEFT OUTER JOIN tblDeviceDeploymentClientList s ON m.ClientID = s.DeviceClientID 
  WHERE IsUsedByJob = 1
  

go
Grant EXEC on spPDAGetMMD to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spPDAGetMMD]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spPDAGetMMD]
GO

Create Procedure dbo.spPDAGetMMD 
 AS
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetMMD
/*
spPDAGetMMD
*/
Go

Grant EXEC on spPDAGetMMD to eCAMS_Role
Go
