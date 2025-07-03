Use CAMS
Go

Alter Procedure dbo.spPDAGetFSPJobEquipmentList 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 21/05/10 10:33 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPJobEquipmentList.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: get job equipment list. D [ActionType]: 1 - INSTALL, 2 - REMOVE.
--		Use shorter field name to reduce XML tag on webservice omit

--22/09/2006 Bo	Added Call Parts
 SET NOCOUNT ON

  --case1: ims job equipments
  SELECT 
	A = CAST(je.JobID as bigint),
	B = CASE ISNULL(je.Serial, '') WHEN 'TBA' THEN '' 
		WHEN 'SERIAL_NUMBER' THEN ''
		ELSE ISNULL(je.Serial, '') END ,
	C = je.MMD_ID,
	D = je.ActionID,
	E = dbo.fnTrimSoftwareHardwareVersion(ISNULL(ei.SoftwareVersion, '')),
	F = dbo.fnTrimSoftwareHardwareVersion(ISNULL(ei.HardwareRevision, '')),
	G = CAST('' AS varchar(16)),
	H = CAST('' AS varchar(5)),
	I = 0,
	K = 0,
	L = dbo.fnGetDeviceSKU(je.MMD_ID, ei.SoftwareVersion, ei.HardwareRevision)

	FROM IMS_Job_Equipment je JOIN IMS_Jobs j ON je.JobID = j.JobID
			JOIN WebCams.dbo.tblUser u ON j.BookedInstaller = u.InstallerID
			left outer join Equipment_Inventory ei on je.Serial = ei.Serial and je.MMD_ID = ei.MMD_ID
	WHERE u.UserID = @UserID 
		AND j.AgentSLADateTime IS NOT NULL
		AND j.AllowPDADownload = 1
		AND je.MMD_ID IS NOT NULL
 UNION
  --case2: ims job parts
  SELECT 
	A = CAST(je.JobID as bigint),
	B = je.PartID,
	C = 'P',   ---parts
	D = je.ActionID,
	E = '',
	F = '',
	G = CAST(ISNULL(je.Qty, '0') AS varchar(16)),  	--NewSerial --> Qty
	H = CAST(ISNULL(je.Qty, '0') as varchar(5)),   	--NewMMDID --> Qty
	I = 0,
	K = 0,
	L = ''		--no SKU for Parts

	FROM IMS_Job_Parts je JOIN IMS_Jobs j ON je.JobID = j.JobID
			JOIN WebCams.dbo.tblUser u ON j.BookedInstaller = u.InstallerID
			JOIN vwIMSPart p ON je.PartID = p.PartID
	WHERE u.UserID = @UserID 
		AND j.AgentSLADateTime IS NOT NULL
		AND j.AllowPDADownload = 1	
 UNION
  --case3: call equipment on device-out
  SELECT 
	A = CAST(je.CallNumber as bigint),
	B = ISNULL(je.Serial, ''),
	C = je.MMD_ID,
	D = 2,		---remove
	E = dbo.fnTrimSoftwareHardwareVersion(ISNULL(je.SoftwareVersion, '')),
	F = dbo.fnTrimSoftwareHardwareVersion(ISNULL(je.HardwareRevision, '')),
	G = CAST('' AS varchar(16)),
	H = CAST('' AS varchar(5)),
	I = 0,
	K = 0,
	L = dbo.fnGetDeviceSKU(je.MMD_ID, je.SoftwareVersion, je.HardwareRevision)

	FROM Call_Equipment je JOIN Calls j ON je.CallNumber = j.CallNumber
			JOIN WebCams.dbo.tblUser u ON j.AssignedTo = u.InstallerID
	WHERE u.UserID = @UserID 
		AND j.RequiredDateTime IS NOT NULL
		AND j.AllowPDADownload = 1
		AND je.MMD_ID IS NOT NULL
 UNION
  --case4: join call equipment on device-in
  SELECT 
	A = CAST(je.CallNumber as bigint),
	B = ISNULL(je.NewSerial, ''),
	C = ISNULL(je.NewMMD_ID, ''),
	D = 1,		--install
	E = dbo.fnTrimSoftwareHardwareVersion(ISNULL(je.NewSoftwareVersion, '')),
	F = dbo.fnTrimSoftwareHardwareVersion(ISNULL(je.NewHardwareRevision, '')),
	G = CAST('' AS varchar(16)),
	H = CAST('' AS varchar(5)),
	I = 0,
	K = 0,
	L = dbo.fnGetDeviceSKU(je.NewMMD_ID, je.NewSoftwareVersion, je.NewHardwareRevision)

	FROM Call_Equipment je JOIN Calls j ON je.CallNumber = j.CallNumber
			JOIN WebCams.dbo.tblUser u ON j.AssignedTo = u.InstallerID
	WHERE u.UserID = @UserID 
		AND j.RequiredDateTime IS NOT NULL
		AND j.AllowPDADownload = 1
		AND je.NewMMD_ID IS NOT NULL

 UNION
  --case5: call job parts
  SELECT 
	A = CAST(je.CallNumber as bigint),
	B = je.PartID,
	C = 'P',   ---parts
	D =  1,
	E = '',
	F = '',
	G = CAST(je.Qty AS varchar(16)),  	--NewSerial --> Qty
	H = CAST(je.Qty as varchar(5)),   	--NewMMDID --> Qty
	I = 0,
	K = 0,
	L = ''		--no SKU for Parts


	FROM Call_Parts je JOIN Calls j ON je.CallNumber = j.CallNumber
			JOIN WebCams.dbo.tblUser u ON j.AssignedTo = u.InstallerID
	WHERE u.UserID = @UserID 
		AND j.RequiredDateTime IS NOT NULL
		AND j.AllowPDADownload = 1

GO

Grant EXEC on spPDAGetFSPJobEquipmentList to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spPDAGetFSPJobEquipmentList 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 12 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/06/05 11:27a $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPJobEquipmentList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetFSPJobEquipmentList @UserID = @UserID
/*
spPDAGetFSPJobEquipmentList 199513
*/
Go

Grant EXEC on spPDAGetFSPJobEquipmentList to eCAMS_Role
Go

