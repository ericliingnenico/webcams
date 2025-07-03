Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spPDAGetFSPEquipmentInventory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spPDAGetFSPEquipmentInventory]
GO


Create Procedure dbo.spPDAGetFSPEquipmentInventory 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 21/05/10 10:33 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPEquipmentInventory.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetFSPEquipmentInventory @UserID = @UserID
/*
spPDAGetFSPEquipmentInventory 199516
*/
Go

Grant EXEC on spPDAGetFSPEquipmentInventory to eCAMS_Role
Go

Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spPDAGetFSPEquipmentInventory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spPDAGetFSPEquipmentInventory]
GO


Create Procedure dbo.spPDAGetFSPEquipmentInventory 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 2/04/03 17:01 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spPDAGetFSPEquipmentInventory.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: get fsp's equipment inventory, all conditions. USe short field name to reduce the XML tag on webservice

 SET NOCOUNT ON

 SELECT
	A = ei.Serial,
	B = ei.MMD_ID,
	C = ISNULL(ei.ClientID, ''),
	D = ISNULL(ei.Condition, ''),
	E = ISNULL(ei.PacketNumber, ''),
	F = dbo.fnTrimSoftwareHardwareVersion(ISNULL(ei.SoftwareVersion, '')),
	G = dbo.fnTrimSoftwareHardwareVersion(ISNULL(ei.HardwareRevision, ''))
 	FROM Equipment_Inventory ei JOIN WebCams.dbo.tblUser u ON ei.Location = u.InstallerID
	WHERE u.UserID = @UserID 


GO

Grant EXEC on spPDAGetFSPEquipmentInventory to eCAMS_Role
Go
