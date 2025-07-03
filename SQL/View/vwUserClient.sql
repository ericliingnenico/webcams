USE [WebCAMS]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwUserClient]'))
	DROP VIEW [dbo].[vwUserClient]

GO

create view [dbo].[vwUserClient] as
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/08/08 12:58p $-->
--<!--$$Logfile: /eCAMSSource/SQL/View/vwUserClient.sql $-->
--<!--$$NoKeywords: $-->
 Select distinct UserID, ClientID From tblUserClientDeviceType

/*
select * from vwUserClient
*/

Go

grant select on vwUserClient to eCAMS_Role
Go
