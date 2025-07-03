Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutFSPStockReturned]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebPutFSPStockReturned]
GO

Create Procedure dbo.spWebPutFSPStockReturned 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int OUTPUT,
		@FromLocation int,
		@ToLocation int,
		@DateReturned datetime,
		@ReferenceNo varchar(30),
		@Note varchar(1000),
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 17/11/05 4:06p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPStockReturned.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add FSP stock returned batch details

 SET NOCOUNT ON
 DECLARE @InstallerID int,
	@ret int


 SELECT @ret = 0

 --Get FSPID
 SELECT @InstallerID = InstallerID
   FROM WebCams.dbo.tblUser
   WHERE UserID = @UserID

 --null value, then use user's installerID
 SELECT @FromLocation = ISNULL(@FromLocation, @InstallerID)

 --verify if the depot is in user's FSP group
 IF EXISTS(SELECT 1 FROM dbo.fnGetLocationChildrenExt(@InstallerID) WHERE  Location = @FromLocation)
  BEGIN
	IF EXISTS(SELECT 1 FROM tblFSPStockReturned WHERE BatchID = @BatchID)
	 BEGIN
		--The batch exists, update tblFSPStockReturned with the details
		UPDATE tblFSPStockReturned
		   SET DateReturned = @DateReturned,
			ReferenceNo = @ReferenceNo,
			Note = @Note
		  WHERE BatchID = @BatchID

		SELECT @ret = @@ERROR
	 END
	ELSE
	 BEGIN
		--not exist, add new record
		INSERT tblFSPStockReturned (
					SourceID,
					FromLocation,
					ToLocation,
					DateReturned,
					ReferenceNo,
					UserID,
					Status,
					Note,
					LogDate)
				VALUES (
					@SourceID,
					@FromLocation,
					@ToLocation,
					@DateReturned,
					@ReferenceNo,
					@UserID,
					@Status,
					@Note,
					GetDate())

		SELECT @ret = @@ERROR

		SELECT @BatchID = IDENT_CURRENT('tblFSPStockReturned')

	 END
  END

GO

Grant EXEC on spWebPutFSPStockReturned to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutFSPStockReturned]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebPutFSPStockReturned]
GO


Create Procedure dbo.spWebPutFSPStockReturned 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int OUTPUT,
		@FromLocation int,
		@ToLocation int,
		@DateReturned datetime,
		@ReferenceNo varchar(30),
		@Note varchar(1000),
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPStockReturned.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebPutFSPStockReturned @UserID = @UserID, 
				@SourceID = @SourceID,
				@BatchID = @BatchID OUTPUT,
				@FromLocation = @FromLocation,
				@ToLocation = @ToLocation,
				@DateReturned = @DateReturned,
				@ReferenceNo = @ReferenceNo,
				@Note = @Note,
				@Status = @Status

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*

declare @BatchID int

exec dbo.spWebPutFSPStockReturned @UserID = 199663, 
				@SourceID = 'P',
				@BatchID = @BatchID OUTPUT,
				@FromLocation = 3003,
				@ToLocation = 300,
				@DateReturned = '2005-11-15',
				@ReferenceNo = '123456789',
				@Note = 'this is a test.',
				@Status = 'O'

select @BatchID

select * from tblFSPStockReturned

*/
GO

Grant EXEC on spWebPutFSPStockReturned to eCAMS_Role
Go
