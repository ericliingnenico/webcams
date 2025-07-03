Use CAMS
Go
Alter Procedure dbo.spPDAGetFSPJobEquipmentListExt 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 21/05/10 10:33 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPJobEquipmentListExt.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: get job equipment list. D [ActionType]: 1 - INSTALL, 2 - REMOVE.
--		Use shorter field name to reduce XML tag on webservice omit
--Notes: This proc is based on temporary table #Job & #call passed in from caller-spPDAGetFSPJobList
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

	FROM IMS_Job_Equipment je JOIN #Job j ON je.JobID = j.JobID
			left outer join Equipment_Inventory ei on je.Serial = ei.Serial and je.MMD_ID = ei.MMD_ID
	WHERE je.MMD_ID IS NOT NULL
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

	FROM IMS_Job_Parts je JOIN #Job j ON je.JobID = j.JobID
			JOIN vwIMSPart p ON je.PartID = p.PartID
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

	FROM Call_Equipment je JOIN #Call j ON je.CallNumber = j.CallNumber
	WHERE je.MMD_ID IS NOT NULL
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

	FROM Call_Equipment je JOIN #Call j ON je.CallNumber = j.CallNumber
	WHERE je.NewMMD_ID IS NOT NULL

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

	FROM Call_Parts je JOIN #Call j ON je.CallNumber = j.CallNumber

GO

Grant EXEC on spPDAGetFSPJobEquipmentListExt to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spPDAGetFSPJobEquipmentListExt 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 17/11/04 1:07p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPJobEquipmentListExt.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetFSPJobEquipmentListExt @UserID = @UserID
/*
spPDAGetFSPJobEquipmentListExt 199513
*/
Go

Grant EXEC on spPDAGetFSPJobEquipmentListExt to eCAMS_Role
Go
