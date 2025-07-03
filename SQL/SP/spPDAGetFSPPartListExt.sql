Use CAMS
Go
Alter Procedure dbo.spPDAGetFSPPartListExt 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 20/09/06 3:57p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPPartListExt.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: get part description list for the given FSP. This will reduce the download data by using the shorter field name.
--Notes: This proc is based on temporary table #Job & #call passed in from caller-spPDAGetFSPJobList
  SELECT Distinct
	A = p.PartID,
	B = p.PartDescription
	FROM vwIMSPart p JOIN IMS_Job_Parts jp ON p.PartID = jp.PartID
			JOIN #Job j ON jp.JobID = j.JobID

GO

Grant EXEC on spPDAGetFSPPartListExt to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spPDAGetFSPPartListExt 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 4 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 17/11/04 1:07p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPPartListExt.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetFSPPartListExt @UserID = @UserID
/*
spPDAGetFSPPartListExt 199516
*/
Go

Grant EXEC on spPDAGetFSPPartListExt to eCAMS_Role
Go

