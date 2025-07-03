Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebCloseFSPStockTakeAndSendReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebCloseFSPStockTakeAndSendReport]
GO


Create Procedure dbo.spWebCloseFSPStockTakeAndSendReport 
	(
		@UserID int,
		@BatchID int
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/06/10 10:35 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseFSPStockTakeAndSendReport.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Close a FSP stocktake batch and email report to FSP/StockControl

 SET NOCOUNT ON
 DECLARE @ret int

 SELECT @ret = 0

 --verify user
 IF NOT EXISTS(SELECT 1 FROM tblFSPStockTake WHERE UserID = @UserID AND BatchID = @BatchID)
  BEGIN
	--the batch is not belong to this user, return
	RETURN -1
  END

 --close the batch
 UPDATE tblFSPStockTake
    SET Status = 'C'
  WHERE BatchID = @BatchID


 --email report
 EXEC @ret = dbo.spWebSendFSPStockTakeReport 
		@UserID = @UserID,
		@BatchID = @BatchID
 RETURN @ret
GO

Grant EXEC on spWebCloseFSPStockTakeAndSendReport to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebCloseFSPStockTakeAndSendReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebCloseFSPStockTakeAndSendReport]
GO


Create Procedure dbo.spWebCloseFSPStockTakeAndSendReport 
	(
		@UserID int,
		@BatchID int
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseFSPStockTakeAndSendReport.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebCloseFSPStockTakeAndSendReport @UserID = @UserID, 
				@BatchID = @BatchID
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

/*


spWebCloseFSPStockTakeAndSendReport @UserID = 199649,
		@BatchID = 1

*/

GO

Grant EXEC on spWebCloseFSPStockTakeAndSendReport to eCAMS_Role
Go
