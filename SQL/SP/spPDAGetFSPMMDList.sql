Use WebCAMS
Go

Alter Procedure dbo.spPDAGetFSPMMDList 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 10 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/06/05 11:28a $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPMMDList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetFSPMMDList @UserID = @UserID
/*
spPDAGetFSPMMDList 199516
*/
Go

Grant EXEC on spPDAGetFSPMMDList to eCAMS_Role
Go

Use CAMS
Go

Alter Procedure dbo.spPDAGetFSPMMDList 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 2/04/03 17:01 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spPDAGetFSPMMDList.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: get mmd list for the given FSP. This will reduce the download data.
DECLARE @InstallerID int

 --get installer id
  SELECT @InstallerID = InstallerID
    FROM WebCAMS.dbo.tblUser
   WHERE UserID = @UserID

  SELECT 
	A = '_ALL_',
	B = '_ALL_',
	C = '',
	D = 'ALL'
  UNION
  --case1: join equipment inventory, all devices
  SELECT 
	A = m.MMD_ID,
	B = ISNULL(m.Maker, ''),
	C = ISNULL(m.Model, ''),
	D = ISNULL(m.Device, '')
	
	FROM M_M_D m JOIN Equipment_Inventory ei ON m.MMD_ID = ei.MMD_ID
			JOIN dbo.fnGetLocationFamily(@InstallerID) l ON ei.Location = l.Location
 UNION
  --case2: join call equipment on old device
  SELECT 
	A = m.MMD_ID,
	B = ISNULL(m.Maker, ''),
	C = ISNULL(m.Model, ''),
	D = ISNULL(m.Device, '')
	
	FROM M_M_D m JOIN Call_Equipment ce ON m.MMD_ID = ce.MMD_ID
			JOIN Calls c ON ce.CallNumber = c.CallNumber
			JOIN WebCams.dbo.tblUser u ON c.AssignedTo = u.InstallerID
	WHERE u.UserID = @UserID 
		AND c.RequiredDateTime IS NOT NULL
 UNION
  --case3: join call equipment on new device
  SELECT 
	A = m.MMD_ID,
	B = ISNULL(m.Maker, ''),
	C = ISNULL(m.Model, ''),
	D = ISNULL(m.Device, '')
	
	FROM M_M_D m JOIN Call_Equipment ce ON m.MMD_ID = ce.NewMMD_ID
			JOIN Calls c ON ce.CallNumber = c.CallNumber
			JOIN WebCams.dbo.tblUser u ON c.AssignedTo = u.InstallerID
	WHERE u.UserID = @UserID 
		AND c.RequiredDateTime IS NOT NULL
 UNION
  --case2: join ims job equipment
  SELECT 
	A = m.MMD_ID,
	B = ISNULL(m.Maker, ''),
	C = ISNULL(m.Model, ''),
	D = ISNULL(m.Device, '')
	
	FROM M_M_D m JOIN IMS_Job_Equipment je ON m.MMD_ID = je.MMD_ID
			JOIN IMS_Jobs j ON je.JobID = j.JobID
			JOIN WebCams.dbo.tblUser u ON j.BookedInstaller = u.InstallerID
	WHERE u.UserID = @UserID 
		AND j.AgentSLADateTime IS NOT NULL


GO

Grant EXEC on spPDAGetFSPMMDList to eCAMS_Role
Go
