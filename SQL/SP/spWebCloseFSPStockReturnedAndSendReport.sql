
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebCloseFSPStockReturnedAndSendReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebCloseFSPStockReturnedAndSendReport]
GO


Create Procedure dbo.spWebCloseFSPStockReturnedAndSendReport 
	(
		@UserID int,
		@BatchID int,
		@NoOfBox int
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 11/06/08 10:03a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseFSPStockReturnedAndSendReport.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Close a FSP stock Returned batch and email report to FSP/StockControl

 SET NOCOUNT ON
 DECLARE @ret int

 SELECT @ret = 0

 --verify user
 IF NOT EXISTS(SELECT 1 FROM tblFSPStockReturned WHERE UserID = @UserID AND BatchID = @BatchID)
  BEGIN
	--the batch is not belong to this user, return
	RETURN -1
  END

 --close the batch
 UPDATE tblFSPStockReturned
    SET Status = 'C',
		NoOfBox = @NoOfBox
  WHERE BatchID = @BatchID


 --email report
 EXEC @ret = dbo.spWebSendFSPStockReturnedReport 
		@UserID = @UserID,
		@BatchID = @BatchID
 RETURN @ret
GO

Grant EXEC on spWebCloseFSPStockReturnedAndSendReport to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebCloseFSPStockReturnedAndSendReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebCloseFSPStockReturnedAndSendReport]
GO


Create Procedure dbo.spWebCloseFSPStockReturnedAndSendReport 
	(
		@UserID int,
		@BatchID int,
		@NoOfBox int
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseFSPStockReturnedAndSendReport.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebCloseFSPStockReturnedAndSendReport @UserID = @UserID, 
				@BatchID = @BatchID,
				@NoOfBox = @NoOfBox
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret


GO

Grant EXEC on spWebCloseFSPStockReturnedAndSendReport to eCAMS_Role
Go
