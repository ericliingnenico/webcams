USE [WebCAMS]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwUserClientMMD]'))
	DROP VIEW [dbo].[vwUserClientMMD]

GO

create view vwUserClientMMD as
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/08/08 1:44p $-->
--<!--$$Logfile: /eCAMSSource/SQL/View/vwUserClientMMD.sql $-->
--<!--$$NoKeywords: $-->
 Select distinct u.UserID, 
			u.ClientID ,
			d.MMD as MMD_ID
		From tblUserClientDeviceType u WITH (NOLOCK) 
						left outer join CAMS.dbo.tblJobMMDPartDefault d WITH (NOLOCK) ON u.ClientID = d.ClientID and u.DeviceType = d.DeviceType and d.DefaultType = 'E'

/*
select * from vwUserClientMMD

*/

Go

grant select on vwUserClientMMD to eCAMS_Role
Go
