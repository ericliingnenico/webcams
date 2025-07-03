USE WebCAMS
GO

if object_id('tr_tblFailureLoginLog_FailedNthTime') is not null
	DROP TRIGGER dbo.tr_tblFailureLoginLog_FailedNthTime
GO

CREATE TRIGGER [dbo].[tr_tblFailureLoginLog_FailedNthTime]
   ON [dbo].[tblFailureLoginLog]
   FOR INSERT NOT FOR REPLICATION
AS 
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 25/05/15 13:02 $-->
--<!--$$Logfile: /eCAMSSource/SQL/Trigger/tr_tblFailureLoginLog_FailedNthTime.sql $-->
--<!--$$NoKeywords: $-->
/*
Disable the account if failed to login 10 times
*/
BEGIN
	SET NOCOUNT ON

	declare @MaxLogDate datetime,
			@TodaysDate date = getdate(),
			@UserID int,
			@NthTime int = 10,
			@EmailAddress varchar(200)

	select @MaxLogDate = max(al.LogDate) -- get the latest successful login
		from inserted i 
			join tbluser u on i.EmailAddress = u.EmailAddress 
			join tblActionLog al with (nolock) on u.UserID = al.userid
		where cast(al.LogDate as date) = @TodaysDate
			and al.ActionTypeID in (1, 2, 3, 4, 6, 8)	-- Web (eCAMS) User Login, Mobile (mCAMS) User Login, PocketPC (pCAMS) User Login, eCAMS PocketPC Portal - User Login, PasswordReset

	select @MaxLogDate = isnull(@MaxLogDate, @TodaysDate)

	if exists(select 1 from inserted i -- check any succeeding login failure and then count -- 10th time disable it
					join tblFailureLoginLog f with (nolock) on i.EmailAddress = f.EmailAddress
					where cast(f.LogDateTime as date) = @TodaysDate				-- same day
						and f.LogDateTime > @MaxLogDate							-- after any successful login within today
					having count(f.LogID) >= @NthTime)
		begin
			update u set  IsActive = 0
				from tblUser u 
					join inserted i on u.EmailAddress = i.EmailAddress

			select top 1 @UserID = UserID from tblUser u (nolock) where exists(select 1 from inserted i where u.EmailAddress = i.EmailAddress)
			select top 1 @EmailAddress = EmailAddress from inserted
			insert tblActionLog 
				select 7, '<EmailAddress>' + isnull(@EmailAddress,'') + '</EmailAddress><LoginFailedNTimes>' + cast(@NthTime as varchar) + '</LoginFailedNTimes>', @UserID, getdate()	--Auto Deactivate User-LoginFiledNTimes
		end

END
GO
/*
select top 20 * from tblFailureLoginLog order by LogID desc
select top 20 * from tblActionLog order by LogID desc
*/