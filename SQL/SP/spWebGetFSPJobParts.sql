Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPJobParts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPJobParts]
GO


Create Procedure dbo.spWebGetFSPJobParts 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 5/04/13 14:02 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobParts.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPJobParts @UserID = @UserID, @JobID = @JobID
/*
spWebGetFSPJobParts 199663, 20050303172
spWebGetFSPJobParts 199663, 505646

312691
*/
Go

Grant EXEC on spWebGetFSPJobParts to eCAMS_Role
Go

Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPJobParts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetFSPJobParts]
GO


Create Procedure dbo.spWebGetFSPJobParts 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/03/03 17:02 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetFSPJobParts.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get Job Equipment
 DECLARE 
	@Location int,
	@JobFSP int
	



 SELECT @Location = InstallerID FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID


 --cache Location Family
 SELECT * 
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamilyExt(@Location)


 
 IF LEN(@JobID) = 11
  BEGIN
	--get call info
	SELECT @JobFSP = AssignedTo
	  FROM Calls
	 WHERE CallNumber = @JobID


	--verify the job is belong to this user
	IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
	 BEGIN
		SELECT Keys = je.PartID,
			[Action] = 'IN',
			PartID = je.PartID,
			Qty = je.Qty,
			Device = m.PartDescription
			FROM Call_Parts je JOIN vwIMSPart m ON je.PartID = m.PartID
			WHERE CallNumber = @JobID

	 END

  END
 ELSE
  BEGIN
	SELECT @JobFSP = BookedInstaller
	  FROM IMS_Jobs 
 	 WHERE JobID = @JobID

	--verify the job is belong to this user
	IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
	 BEGIN
		 SELECT Keys = je.PartID,
			[Action] = CASE WHEN je.ActionID = 2 THEN 'OUT' ELSE 'IN' END,		 
			PartID = je.PartID,
			Qty = je.Qty,
			Device = m.PartDescription
			FROM ims_job_parts je  JOIN vwIMSPart m ON je.PartID = m.PartID
			WHERE JobID = @JobID
	
	 END
  END
/*
dbo.spWebGetFSPJobParts 
		@UserID =199649,
		@JobID =791919

select * from webCAMS.dbo.tblUser
 where emailaddress = 'dev101'
	SELECT PartID = PartID,
		Device = PartDescription
		FROM vwIMSPart
		WHERE ClientID = 'boq'


*/
GO
Grant EXEC on spWebGetFSPJobParts to eCAMS_Role
Go


