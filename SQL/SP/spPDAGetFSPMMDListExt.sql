Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].spPDAGetFSPMMDListExt') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].spPDAGetFSPMMDListExt
GO


Create Procedure dbo.spPDAGetFSPMMDListExt 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/06/05 11:35a $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPMMDListExt.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: get mmd list for the given FSP. This will reduce the download data.
--Notes: This proc is based on temporary table #Job & #call passed in from caller-spPDAGetFSPJobList
DECLARE @InstallerID int

 --get installer id
  SELECT @InstallerID = InstallerID
    FROM WebCAMS.dbo.tblUser
   WHERE UserID = @UserID

  --create temp table to store MMD_ID
  SELECT MMD_ID INTO #mmd
    FROM M_M_D  
   WHERE 1 = 2

 --get MMD_ID from Equipment Inventory
 INSERT #mmd
 SELECT DISTINCT MMD_ID
   FROM Equipment_Inventory ei
	JOIN dbo.fnGetLocationFamily(@InstallerID) l ON ei.Location = l.Location

 INSERT #mmd
 SELECT DISTINCT MMD_ID
   FROM Call_Equipment ce JOIN #Call c ON ce.CallNumber =  c.CallNumber

 INSERT #mmd
 SELECT DISTINCT NewMMD_ID
   FROM Call_Equipment ce JOIN #Call c ON ce.CallNumber =  c.CallNumber

 INSERT #mmd
 SELECT DISTINCT MMD_ID
   FROM IMS_Job_Equipment je JOIN #Job j ON je.JobID = j.JobID

  SELECT 
	A = '_ALL_',
	B = '_ALL_',
	C = '',
	D = 'ALL'
  UNION
  SELECT 
	A = m.MMD_ID,
	B = ISNULL(m.Maker, ''),
	C = ISNULL(m.Model, ''),
	D = ISNULL(m.Device, '')
	
	FROM M_M_D m JOIN #mmd t ON m.MMD_ID = t.MMD_ID

GO

Grant EXEC on spPDAGetFSPMMDListExt to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].spPDAGetFSPMMDListExt') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].spPDAGetFSPMMDListExt
GO


Create Procedure dbo.spPDAGetFSPMMDListExt 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 2/06/04 11:14a $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPMMDListExt.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetFSPMMDListExt @UserID = @UserID
/*
spPDAGetFSPMMDListExt 199516
*/
Go

Grant EXEC on spPDAGetFSPMMDListExt to eCAMS_Role
Go
