Use CAMS
Go

IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebGetFSPEscalateReason' and type = 'p')
	drop procedure dbo.spWebGetFSPEscalateReason
go


Create Procedure dbo.spWebGetFSPEscalateReason 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/01/15 14:02 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPEscalateReason.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add FSP stock returned to tblFSPStockReturnedLog


 --Get Location for the user
 IF EXISTS(SELECT 1 FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID)
  BEGIN
		select EscalateReasonID=0,
			EscalateReason = 'Please Select',
			DisplayOrder = -1
		union
		SELECT EscalateReasonID,
			EscalateReason,
			DisplayOrder
			FROM tblFSPEscalateReason
			where IsActive = 1
			Order by DisplayOrder

  END
 RETURN @@ERROR

GO

Grant EXEC on spWebGetFSPEscalateReason to eCAMS_Role
Go


Use WebCAMS
Go


IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebGetFSPEscalateReason' and type = 'p')
	drop procedure dbo.spWebGetFSPEscalateReason
go

Create Procedure dbo.spWebGetFSPEscalateReason 
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
 EXEC Cams.dbo.spWebGetFSPEscalateReason 
		@UserID = @UserID


/*

spWebGetFSPEscalateReason
		@UserID = 199955

		
*/
Go

Grant EXEC on spWebGetFSPEscalateReason to eCAMS_Role
Go

