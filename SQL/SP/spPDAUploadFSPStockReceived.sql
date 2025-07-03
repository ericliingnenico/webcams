
Use WebCAMS
Go

Alter Procedure dbo.spPDAUploadFSPStockReceived 
	(
		@UserID int,
		@BatchID int,
		@Serial varchar(16)
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/11/04 5:31p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAUploadFSPStockReceived.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Call CAMS.dbo.spWebAddFSPStockReceivedLog to add device received to tblFSPStockReceivedLog
 SET NOCOUNT ON

 EXEC dbo.spWebAddFSPStockReceivedLog 
		@UserID = @UserID,
		@BatchID = @BatchID,
		@Serial = @Serial

/*

spPDAUploadFSPStockReceived @UserID = 199516,
		@Serial = 
*/
Go

Grant EXEC on spPDAUploadFSPStockReceived to eCAMS_Role
Go
