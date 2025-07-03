Use WebCAMS
Go

Alter Procedure dbo.spPDAGetFSPPartList 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 20/09/06 3:57p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPPartList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetFSPPartList @UserID = @UserID
/*
spPDAGetFSPPartList 199516
*/
Go

Grant EXEC on spPDAGetFSPPartList to eCAMS_Role
Go

Use CAMS
Go

Alter Procedure dbo.spPDAGetFSPPartList 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 2/04/03 17:01 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spPDAGetFSPPartList.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: get part description list for the given FSP. This will reduce the download data by using the shorter field name.

  SELECT Distinct
	A = p.PartID,
	B = p.PartDescription
	FROM vwIMSPart p JOIN IMS_Job_Parts jp ON p.PartID = jp.PartID
			JOIN IMS_Jobs j ON jp.JobID = j.JobID
			JOIN WebCams.dbo.tblUser u ON j.BookedInstaller = u.InstallerID
	WHERE u.UserID = @UserID 
		AND j.AgentSLADateTime IS NOT NULL
		AND j.AllowPDADownload = 1

GO

Grant EXEC on spPDAGetFSPPartList to eCAMS_Role
Go
