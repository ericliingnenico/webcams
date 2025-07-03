Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPTask 
	(
		@UserID int,
		@TaskID int
	)
	AS
--<!--$$Revision: 4 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/09/04 1:16p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPTask.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPTask @UserID = @UserID, @TaskID = @TaskID
/*

spWebGetFSPTask 199611, null

select * from webcams.dbo.tblUser
*/
GO

Grant EXEC on spWebGetFSPTask to eCAMS_Role
Go


Use CAMS
Go

Alter Procedure dbo.spWebGetFSPTask 
	(
		@UserID int,
		@TaskID int
	)
	AS
--<!--$$Revision: 4 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/04/03 13:04 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetFSPTask.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @InstallerID int

 --Get FSPID
 SELECT @InstallerID = InstallerID 
   FROM WebCams.dbo.tblUser
   WHERE UserID = @UserID

 SELECT 
	@UserID,  --Used for databinding on data adapter update
	t.*,
	DefaultCarrierID = CASE WHEN t.CarrierID IS NULL THEN
				CASE WHEN ToLocationDesc LIKE '%AAE' THEN 1
				     WHEN ToLocationDesc LIKE '%Star%Track%' THEN 2
				ELSE
				    NULL
				END
			   ELSE
				t.CarrierID
			   END
				
	FROM vwTaskFax t JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON t.AssignedTo = l.Location
	WHERE  TaskID = ISNULL(@TaskID, TaskID)
	

 EXEC dbo.spGetCarrier NULL
GO

Grant EXEC on spWebGetFSPTask to eCAMS_Role
Go
