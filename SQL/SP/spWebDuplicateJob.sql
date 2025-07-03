Use WebCAMS
Go

if exists(select 1 from sysobjects where name = 'spWebDuplicateJob')
 drop proc spWebDuplicateJob
Go

create PROCEDURE dbo.spWebDuplicateJob 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20),
		@NewTerminalID varchar(20),
		@NewCAIC varchar(20),
		@NewJobID int OUTPUT
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-03-15 14:52:58$-->
--<!--$ModifiedBy: Bo Li <bo.li@bambora.com>$-->
--<!--$Comment: icm-57$-->
--<!--$Commit$-->
---Purpose: duplicate job

DECLARE @ret int,
	@LoggedBy smallint

 SET NOCOUNT ON

 --init 
 select @ret = -1

 if not exists(select 1 from tblUser u join vwUserClient uc on u.UserID = uc.UserID and uc.ClientID = @ClientID and u.UserID = @UserID)
  begin
	raiserror('The user has no permission to log job, aborted', 16, 1)
	goto Exit_Handle
  end


 select @LoggedBy = CAMS.dbo.fnToggleWebUserID(@UserID)

 exec @ret = CAMS.dbo.spDuplicateJobWithNewTIDExt 
					@ClientID = @ClientID,
					@TerminalID = @TerminalID,
					@NewTerminalID = @NewTerminalID,
					@NewCAIC = @NewCAIC,
					@NewJobID = @NewJobID OUTPUT,
					@LoggedBy = @LoggedBy

--Return
Exit_Handle:
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

/*
spWebDuplicateJob 199955, 'boq', '30015108', 4
select * from webCAMS.dbo.tblUSer
 where emailaddress = 'boq'


*/
Go

Grant EXEC on spWebDuplicateJob to eCAMS_Role
Go

