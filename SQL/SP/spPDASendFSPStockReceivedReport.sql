Use WebCAMS
Go

Alter Procedure dbo.spPDASendFSPStockReceivedReport 
	(
		@UserID int,
		@BatchID int
	)
	AS
--<!--$$Revision: 16 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/11/04 5:31p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDASendFSPStockReceivedReport.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Send FSP stock received report on a batch
 SET NOCOUNT ON

 EXEC dbo.spWebSendFSPStockReceivedReport 
		@UserID = @UserID,
		@BatchID = @BatchID

/*


spPDASendFSPStockReceivedReport @UserID = 199512,
		@BatchID = 
*/
Go

Grant EXEC on spPDASendFSPStockReceivedReport to eCAMS_Role
Go
