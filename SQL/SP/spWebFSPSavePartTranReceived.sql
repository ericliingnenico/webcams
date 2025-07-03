use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebFSPSavePartTranReceived' and type = 'p')
	drop proc spWebFSPSavePartTranReceived
go

create proc spWebFSPSavePartTranReceived (
	@UserID int,
	@TranIDs varchar(8000),
	@QtyReceiveds varchar(8000))
--<!--$$Revision: 4 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/05/11 11:43 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebFSPSavePartTranReceived.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: FSPs acknowledge IMS Parts Received over web portal
as
 declare @FSPID int,
	@ret int,
	@StartedTransaction BIT

 --init
 SET NOCOUNT ON
 SET @ret = 0
 set @StartedTransaction = 0


 SELECT @FSPID = InstallerID 
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID


 BEGIN TRY

 	IF @@TRANCOUNT = 0 
	BEGIN
		BEGIN TRANSACTION
		SET @StartedTransaction = 1
	END

	set @FSPID = @FSPID * -1
	exec spPIMReceiveStockRequest @RequestIDList = @TranIDs
								,@QuantityReceivedList = @QtyReceiveds
								,@LoggedBy = @FSPID


	IF @StartedTransaction = 1 	
		COMMIT TRANSACTION	
END TRY
BEGIN CATCH
	IF @StartedTransaction = 1 
		ROLLBACK TRANSACTION
	
	EXEC master.dbo.upGetErrorInfo

END CATCH

/*
 EXEC spWebFSPSavePartTranReceived @UserID = 199512,
			@TranIDs = '1,2',
			@QtyReceiveds = '10,20'

select * from tblUser

select * from cams.dbo.tblIMSPartTran

select * from cams.dbo.tblIMSPartTranHistory

select * from cams.dbo.tblIMSPartInventory

*/

Go

GRANT EXEC ON spWebFSPSavePartTranReceived TO CALLSYSUSERS, eCAMS_Role
go

use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebFSPSavePartTranReceived' and type = 'p')
	drop proc spWebFSPSavePartTranReceived
go

create proc spWebFSPSavePartTranReceived (
	@UserID int,
	@TranIDs varchar(8000),
	@QtyReceiveds varchar(8000))
as
DECLARE @ret int
 SET NOCOUNT ON
 EXEC @ret = CAMS.dbo.spWebFSPSavePartTranReceived @UserID = @UserID,
				@TranIDs = @TranIDs,
				@QtyReceiveds = @QtyReceiveds


 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
Go

GRANT EXEC ON spWebFSPSavePartTranReceived TO eCAMS_Role
go



