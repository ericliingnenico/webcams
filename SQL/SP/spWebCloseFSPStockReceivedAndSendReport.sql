
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebCloseFSPStockReceivedAndSendReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebCloseFSPStockReceivedAndSendReport]
GO


Create Procedure dbo.spWebCloseFSPStockReceivedAndSendReport 
	(
		@UserID int,
		@BatchID int
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 2/07/08 12:15p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseFSPStockReceivedAndSendReport.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Close a FSP stock received batch and email report to FSP/StockControl

 SET NOCOUNT ON
 DECLARE @ret int

 SELECT @ret = 0

 --verify user
 IF NOT EXISTS(SELECT 1 FROM tblTMPFSPStockReceived WHERE UserID = @UserID AND BatchID = @BatchID)
  BEGIN
	--the batch is not belong to this user, return
	RETURN -1
  END

 --close the batch
 UPDATE tblTMPFSPStockReceived
    SET Status = 'C'
  WHERE BatchID = @BatchID

 --Reconcile tblFSPStockReceived with tblTMPFSPStockReceived
 UPDATE t
	SET	t.ReconciledLogID = f.LogID
  FROM tblFSPStockReceivedLog f JOIN tblTMPFSPStockReceivedLog t ON f.Serial = t.Serial AND f.MMD_ID = t.MMD_ID
 WHERE t.BatchID = @BatchID
	AND f.ScanAtArrival IS NULL
	AND t.ReconciledLogID IS NULL

 UPDATE f
	SET f.ScanAtArrival = t.ScanAtArrival,
		f.CaseID = t.CaseID
  FROM tblFSPStockReceivedLog f JOIN tblTMPFSPStockReceivedLog t ON f.Serial = t.Serial AND f.MMD_ID = t.MMD_ID
 WHERE t.BatchID = @BatchID
	AND f.ScanAtArrival IS NULL
	AND t.ReconciledLogID IS NOT NULL


 --email report
 EXEC @ret = dbo.spWebSendFSPStockReceivedReport 
		@UserID = @UserID,
		@BatchID = @BatchID

 RETURN @ret
GO

Grant EXEC on spWebCloseFSPStockReceivedAndSendReport to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebCloseFSPStockReceivedAndSendReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebCloseFSPStockReceivedAndSendReport]
GO


Create Procedure dbo.spWebCloseFSPStockReceivedAndSendReport 
	(
		@UserID int,
		@BatchID int
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseFSPStockReceivedAndSendReport.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebCloseFSPStockReceivedAndSendReport @UserID = @UserID, 
				@BatchID = @BatchID
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*

exec dbo.spWebCloseFSPStockReceivedAndSendReport @UserID = 199663, 
				@BatchID = @BatchID
select * from tblTMPFSPStockReceived


*/
GO

Grant EXEC on spWebCloseFSPStockReceivedAndSendReport to eCAMS_Role
Go
