USE [WebCAMS]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwUserClientEquipmentCode]'))
	DROP VIEW [dbo].[vwUserClientEquipmentCode]

GO

create view vwUserClientEquipmentCode as
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/08/08 12:58p $-->
--<!--$$Logfile: /eCAMSSource/SQL/View/vwUserClientEquipmentCode.sql $-->
--<!--$$NoKeywords: $-->
 Select distinct u.UserID, 
			u.ClientID ,
			d.EquipmentCode
		From tblUserClientDeviceType u WITH (NOLOCK) 
						left outer join CAMS.dbo.tblDefaultMaintAndEqCode d  WITH (NOLOCK) ON u.ClientID = d.ClientID and u.DeviceType = d.DeviceType


/*
select * from vwUserClientEquipmentCode
*/

Go

grant select on vwUserClientEquipmentCode to eCAMS_Role
Go
