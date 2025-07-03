Use CAMS
Go

IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebGetClientUpdateInfoFieldList' and type = 'p')
	drop procedure dbo.spWebGetClientUpdateInfoFieldList
go


Create Procedure dbo.spWebGetClientUpdateInfoFieldList 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/08/08 1:59p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetClientUpdateInfoFieldList.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add FSP stock returned to tblFSPStockReturnedLog
DECLARE 
	@ClientID varchar(3),
	@JobTypeID tinyint,
	@MerchantName varchar(40)


 --Get Location for the user
 IF EXISTS(SELECT 1 FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID)
  BEGIN
	IF LEN(@JobID) = 11 
	 BEGIN
		SELECT @JobTypeID = 4,
				@ClientID = j.ClientID,
				@MerchantName = LEFT(j.Name, 40)
			FROM Calls j JOIN WebCAMS.dbo.vwUserClient c ON j.ClientID = c.ClientID 
		   WHERE j.CallNumber = @JobID
				AND c.UserID = @UserID
	 END
	ELSE
	 BEGIN
		SELECT @JobTypeID = j.JobTypeID,
				@ClientID = j.ClientID,
				@MerchantName = LEFT(j.Name, 40)
			FROM IMS_Jobs j JOIN WebCAMS.dbo.vwUserClient c on j.ClientID = c.ClientID
			WHERE j.JobID = @JobID
				AND c.UserID = @UserID
	 END
	
	IF @ClientID IS NOT NULL
	 BEGIN
		IF EXISTS(SELECT 1 FROM tblWebClientUpdateInfoFieldList WITH (NOLOCK) WHERE ClientID = @ClientID AND JobTypeID = @JobTypeID)
		 BEGIN
			SELECT f.*,	
					@MerchantName as MerchantName
				FROM tblWebClientUpdateInfoFieldList l WITH (NOLOCK) JOIN tblWebUpdateInfoField f WITH (NOLOCK) ON l.FieldID = f.FieldID 
				WHERE ClientID = @ClientID 
					AND JobTypeID = @JobTypeID
		 END
		ELSE
		 BEGIN
			SELECT f.*,	
					@MerchantName as MerchantName
				FROM tblWebClientUpdateInfoFieldList l WITH (NOLOCK) JOIN tblWebUpdateInfoField f WITH (NOLOCK) ON l.FieldID = f.FieldID 
				WHERE ClientID = @ClientID 
					AND JobTypeID = 0
		 END

	 END
  END
 RETURN @@ERROR

GO

Grant EXEC on spWebGetClientUpdateInfoFieldList to eCAMS_Role
Go


Use WebCAMS
Go


IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebGetClientUpdateInfoFieldList' and type = 'p')
	drop procedure dbo.spWebGetClientUpdateInfoFieldList
go

Create Procedure dbo.spWebGetClientUpdateInfoFieldList 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDACloseJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetClientUpdateInfoFieldList 
		@UserID = @UserID,
		@JobID = @JobID


/*

spWebGetClientUpdateInfoFieldList
		@UserID = 199955,
		@JobID = 20080403331 --588035

select * from tblUser
select * from cams.dbo.IMS_Jobs
 where ClientID = 'boq'


select * from cams.dbo.Calls
 where ClientID = 'boq'

		
*/
Go

Grant EXEC on spWebGetClientUpdateInfoFieldList to eCAMS_Role
Go

