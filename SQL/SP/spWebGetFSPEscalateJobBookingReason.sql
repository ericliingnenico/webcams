Use CAMS
Go

IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebGetFSPEscalateJobBookingReason' and type = 'p')
	drop procedure dbo.spWebGetFSPEscalateJobBookingReason
go


Create Procedure dbo.spWebGetFSPEscalateJobBookingReason 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/01/16 13:53 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPEscalateJobBookingReason.sql $-->
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
			FROM tblFSPEscalateJobBookingReason
			where IsActive = 1
			Order by DisplayOrder

  END
 RETURN @@ERROR

GO

Grant EXEC on spWebGetFSPEscalateJobBookingReason to eCAMS_Role
Go


Use WebCAMS
Go


IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebGetFSPEscalateJobBookingReason' and type = 'p')
	drop procedure dbo.spWebGetFSPEscalateJobBookingReason
go

Create Procedure dbo.spWebGetFSPEscalateJobBookingReason 
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
 EXEC Cams.dbo.spWebGetFSPEscalateJobBookingReason 
		@UserID = @UserID


/*

spWebGetFSPEscalateJobBookingReason
		@UserID = 199955

		
*/
Go

Grant EXEC on spWebGetFSPEscalateJobBookingReason to eCAMS_Role
Go

