
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutFSPStockReceived]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebPutFSPStockReceived]
GO


Create Procedure dbo.spWebPutFSPStockReceived 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int OUTPUT,
		@Depot int,
		@DateReceived datetime,
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 1/07/08 4:36p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPStockReceived.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add FSP stock received batch details

 SET NOCOUNT ON
 DECLARE @InstallerID int,
	@FSPOperator int,
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
	IF EXISTS(SELECT 1 FROM tblTMPFSPStockReceived WHERE BatchID = @BatchID)
	 BEGIN
		--The batch exists, update tblTMPFSPStockReceived with the details
		UPDATE tblTMPFSPStockReceived
		   SET UserID = @UserID,
			SourceID = @SourceID,
			Depot = @Depot,
			DateReceived = @DateReceived,
			Status = @Status
		  WHERE BatchID = @BatchID

		SELECT @ret = @@ERROR
	 END
	ELSE
	 BEGIN
		--not exist, add new record
		INSERT tblTMPFSPStockReceived (
					UserID,
					SourceID,
					Depot,
					DateReceived,
					Status,
					LogDate)
			VALUES (
					@UserID,
					@SourceID,
					@Depot,
					@DateReceived,
					@Status,
					GetDate())

		SELECT @ret = @@ERROR

		SELECT @BatchID = IDENT_CURRENT('tblTMPFSPStockReceived')

	 END
  END

GO

Grant EXEC on spWebPutFSPStockReceived to eCAMS_Role
Go

Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutFSPStockReceived]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebPutFSPStockReceived]
GO


Create Procedure dbo.spWebPutFSPStockReceived 
	(
		@UserID int,
		@SourceID varchar(1),
		@BatchID int OUTPUT,
		@Depot int,
		@DateReceived datetime,
		@Status varchar(1)
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPStockReceived.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebPutFSPStockReceived @UserID = @UserID, 
				@SourceID = @SourceID,
				@BatchID = @BatchID OUTPUT,
				@Depot = @Depot,
				@DateReceived = @DateReceived,
				@Status = @Status

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*

declare @BatchID int

exec dbo.spWebPutFSPStockReceived @UserID = 199663, 
				@SourceID = 'P',
				@BatchID = @BatchID OUTPUT,
				@Depot = 3011,
				@DateReceived = '2004-11-25',
				@Status = 'O'
select @BatchID

select * from tblTMPFSPStockReceived


*/
GO

Grant EXEC on spWebPutFSPStockReceived to eCAMS_Role
Go
