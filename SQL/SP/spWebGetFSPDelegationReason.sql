Use CAMS
Go

IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebGetFSPDelegationReason' and type = 'p')
	drop procedure dbo.spWebGetFSPDelegationReason
go


Create Procedure dbo.spWebGetFSPDelegationReason 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 5/12/13 13:38 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPDelegationReason.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add FSP stock returned to tblFSPStockReturnedLog


 --Get Location for the user
 IF EXISTS(SELECT 1 FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID)
  BEGIN
		SELECT *
			FROM tblFSPDelegationReason
			Order by ReasonID

  END
 RETURN @@ERROR

GO

Grant EXEC on spWebGetFSPDelegationReason to eCAMS_Role
Go


Use WebCAMS
Go


IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebGetFSPDelegationReason' and type = 'p')
	drop procedure dbo.spWebGetFSPDelegationReason
go

Create Procedure dbo.spWebGetFSPDelegationReason 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDACloseJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPDelegationReason 
		@UserID = @UserID


/*
spWebGetFSPDelegationReason
		@UserID = 199955

*/
Go

Grant EXEC on spWebGetFSPDelegationReason to eCAMS_Role
Go

