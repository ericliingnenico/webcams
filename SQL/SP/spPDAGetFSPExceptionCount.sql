
Use CAMS
Go

alter Procedure dbo.spPDAGetFSPExceptionCount 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 24/10/06 3:39p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPExceptionCount.sql $-->
--<!--$$NoKeywords: $-->
---Return a recordset of number of FSP's open jobs with status = 'FSP Exception'
DECLARE @InstallerID int,
	@FSP_EXCEPTION tinyint,
	@Count int

 SELECT @FSP_EXCEPTION = 7, --'FSP EXCEPTION',
	@Count = 0


 SELECT @InstallerID = InstallerID 
   FROM WebCams.dbo.tblUser
  WHERE UserID = @UserID


  SELECT @Count = @Count + Count(*)
    FROM IMS_Jobs 
   WHERE StatusID = @FSP_EXCEPTION
		AND BookedInstaller = @InstallerID

  SELECT @Count = @Count + Count(*)
    FROM Calls 
   WHERE StatusID = @FSP_EXCEPTION
		AND AssignedTo = @InstallerID

 SELECT Count = @Count

GO

Grant EXEC on spPDAGetFSPExceptionCount to eCAMS_Role
Go

Use WebCAMS
Go


alter Procedure dbo.spPDAGetFSPExceptionCount 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 11:41a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spPDAGetFSPExceptionCount.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetFSPExceptionCount 
			@UserID = @UserID

/*
select * from webcams.dbo.tblUser

spPDAGetFSPExceptionCount 199512


spPDAGetFSPExceptionCount 199663
*/
Go

Grant EXEC on spPDAGetFSPExceptionCount to eCAMS_Role
Go
