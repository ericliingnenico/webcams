Use CAMS
Go

if exists(select 1 from sys.procedures where name = 'spWebConfirmKittedPartsUsage')
	drop proc spWebConfirmKittedPartsUsage
go

Create Procedure dbo.spWebConfirmKittedPartsUsage 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 5/04/13 14:02 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebConfirmKittedPartsUsage.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Confirm Kitted Parts USage

DECLARE @ret int,
	@Location int

 --init
 SELECT @ret = 0
 
 --Get Location for the user
 SELECT @Location = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 if @@ROWCOUNT = 0
  begin
	raiserror('Invalid user, abort', 16, 1)
	return -1
  end
  
 if exists(select 1 from tblFSPKitPartUsageConfirmLog where JobID = @JobID)
  begin
	Update tblFSPKitPartUsageConfirmLog
		set UpdatedDateTime = GETDATE()
		where JobID = @JobID
  end
 else
  begin
	insert tblFSPKitPartUsageConfirmLog values(@JobID, GETDATE())
  end

 RETURN @ret
/*
declare @ret  int
exec @ret = dbo.spWebConfirmKittedPartsUsage @UserID = 199663, 
					@JobID = 310352
select @ret



*/
Go

Grant EXEC on spWebConfirmKittedPartsUsage to eCAMS_Role
Go


Use WebCAMS
Go
if exists(select 1 from sys.procedures where name = 'spWebConfirmKittedPartsUsage')
	drop proc spWebConfirmKittedPartsUsage
go

Create Procedure dbo.spWebConfirmKittedPartsUsage 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebCloseFSPJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebConfirmKittedPartsUsage @UserID = @UserID,
		@JobID = @JobID
		
 select @ret

 RETURN @ret
/*

spWebConfirmKittedPartsUsage @UserID = 199516,
		@JobID = 221895
*/
Go

Grant EXEC on spWebConfirmKittedPartsUsage to eCAMS_Role
Go
