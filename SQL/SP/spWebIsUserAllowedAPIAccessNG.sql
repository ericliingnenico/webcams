use CAMS
go

if object_id('spWebIsUserAllowedAPIAccessNG') is null
	exec ('create procedure dbo.spWebIsUserAllowedAPIAccessNG as return 1')
go

alter procedure dbo.spWebIsUserAllowedAPIAccessNG
(
	@UserID int,
	@MethodID int
)
as
--<!--$$Revision: 1 $-->
--<!--$$Author: Chester $-->
--<!--$$Date: 10/09/15 18:39 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebIsUserAllowedAPIAccessNG.sql $-->
--<!--$$NoKeywords: $-->
/*
Purpose: Validate user access, raise error
1: UpdateJobNote
2: CloseJob
3: LogNewJob
4: GetOpenJobList
5: GetJob
6: GetCall
*/	
	set nocount on

	declare @IsApiUser bit

	select @IsApiUser = isnull(a.IsApiUser, 0) from AspNetUsers a where a.LegacyUserId = @UserID
	if @@ROWCOUNT > 0
		begin
			if @IsApiUser = 1 and not exists(select 1 from tblAPIUserMethod a where a.UserID = @UserID and a.MethodID = @MethodID)
				goto Error_Handle
		end
	else
		goto Error_Handle

	return 0

Error_Handle:
	raiserror('User has no access to this method.', 16, 1)
	return -1

/*
declare @ret int
exec @ret = spWebIsUserAllowedAPIAccessNG @UserID = 210001, @MethodID = 5
print @ret
exec @ret = spWebIsUserAllowedAPIAccessNG @UserID = 210001, @MethodID = 2
print @ret
exec @ret = spWebIsUserAllowedAPIAccessNG @UserID = NULL, @MethodID = NULL
print @ret
exec @ret = spWebIsUserAllowedAPIAccessNG @UserID = 210000, @MethodID = 5
print @ret

*/
go


