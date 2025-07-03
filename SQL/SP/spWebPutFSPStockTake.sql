Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutFSPStockTake]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebPutFSPStockTake]
GO

Create Procedure dbo.spWebPutFSPStockTake 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int OUTPUT,
		@Depot int,
		@StockTakeDate datetime,
		@Note varchar(100),
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/06/10 10:35 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPStockTake.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add FSP stocktake batch details

 SET NOCOUNT ON
 DECLARE @InstallerID int,
	@ret int


 SELECT @ret = 0

 --Get FSPID
 SELECT @InstallerID = InstallerID
   FROM WebCams.dbo.tblUser
   WHERE UserID = @UserID

 --null value, then use user's installerID
 SELECT @Depot = ISNULL(@Depot, @InstallerID)

 --verify if the depot is in user's FSP group
 IF EXISTS(SELECT 1 FROM dbo.fnGetLocationChildrenExt(@InstallerID) WHERE  Location = @Depot)
  BEGIN
	IF EXISTS(SELECT 1 FROM tblFSPStockTake WHERE BatchID = @BatchID)
	 BEGIN
		--The batch exists, update tblFSPStockTake with the details
		UPDATE tblFSPStockTake
		   SET Note = @Note
		  WHERE BatchID = @BatchID

		SELECT @ret = @@ERROR
	 END
	ELSE
	 BEGIN
		--not exist, add new record
		INSERT tblFSPStockTake (
					SourceID,
					Depot,
					StockTakeDate,
					UserID,
					Status,
					Note)
				VALUES (
					@SourceID,
					@Depot,
					@StockTakeDate,
					@UserID,
					@Status,
					@Note)

		SELECT @ret = @@ERROR

		SELECT @BatchID = IDENT_CURRENT('tblFSPStockTake')

	 END
  END

GO

Grant EXEC on spWebPutFSPStockTake to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutFSPStockTake]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebPutFSPStockTake]
GO


Create Procedure dbo.spWebPutFSPStockTake 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int OUTPUT,
		@Depot int,
		@StockTakeDate datetime,
		@Note varchar(100),
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPStockTake.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebPutFSPStockTake @UserID = @UserID, 
				@SourceID = @SourceID,
				@BatchID = @BatchID OUTPUT,
				@Depot = @Depot,
				@StockTakeDate = @StockTakeDate,
				@Note = @Note,
				@Status = @Status

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*

declare @BatchID int

exec dbo.spWebPutFSPStockTake @UserID = 199663, 
				@SourceID = 'P',
				@BatchID = @BatchID OUTPUT,
				@Depot = 3003,
				@ToLocation = 300,
				@DateReturned = '2005-11-15',
				@ReferenceNo = '123456789',
				@Note = 'this is a test.',
				@Status = 'O'

select @BatchID

select * from tblFSPStockTake

*/
GO

Grant EXEC on spWebPutFSPStockTake to eCAMS_Role
Go
