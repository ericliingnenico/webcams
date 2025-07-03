USE [WebCAMS]
GO
/****** Object:  StoredProcedure [dbo].[spWebResetUserPWD]    Script Date: 11/11/20 09:14:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Procedure [dbo].[spWebResetUserPWD]
	(
		@EmailAddress	varchar(50),
		@NewPWDText		varchar(50),
		@NewPassword	binary(16),
		@HostInfo	varchar(200)
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 21/05/15 15:40 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebResetUserPWD.sql $-->
--<!--$$NoKeywords: $-->
SET NOCOUNT ON
DECLARE @ret int,
		@MailBody varchar(2000),
		@ErrMsg varchar(200),
		@UserID int

--init
SELECT @ret = 0,
	@ErrMsg = '',
	@HostInfo = isnull(@HostInfo,'') + '<Email>' + ISNULL(@EmailAddress,'') + '</Email>',
	@UserID = 0

begin try
	 --validation
	  --check if user exists
	 if master.dbo.fnIsValidEmail(@EmailAddress) = 0
	  begin
		set @ErrMsg = 'EmailAddress is invalid.Abort.'
		raiserror (@ErrMsg, 16, 1)
	  end

	 if not exists(select 1 from tblUser where EmailAddress = @EmailAddress)
	  begin
		set @ErrMsg = 'User does not exist.Abort.'
		raiserror (@ErrMsg, 16, 1)
	  end

	 if not exists(select 1 from tblUser where EmailAddress = @EmailAddress and IsActive = 1)
	  begin
		set @ErrMsg = 'User has been deactivated.Abort.'
		raiserror (@ErrMsg, 16, 1)
	  end

	 --check email address range
	 if not exists(select 1 from tblControl where Attribute = 'ResetPWDDomainList'
					and CHARINDEX(SUBSTRING(@EmailAddress,CHARINDEX('@',@EmailAddress), LEN(@EmailAddress)-1) , AttrValue)>0 )
	  begin
		set @ErrMsg = 'Invalid Domain Name.Abort.'
		raiserror (@ErrMsg, 16, 1)
	  end
					
	
	 --process
	 update tblUser
		set [Password] = @NewPassword,
			UpdateTime = Getdate(),
			ExpiryDate = DateAdd(d, 60, GetDate())
	  where EmailAddress = @EmailAddress


	select @MailBody = 'Your account password has been reset to: ' + CHAR(10) +
						@NewPWDText  + char(13) + char(13) +
						'Remember to change the password when you login'

	insert into CAMS.dbo.MailTask ([To], [From], [Subject], [Body], [Type], [Priority], [State], [LogBy])
		values (@EmailAddress, 'SQLMail@Keycorp.net', '', @MailBody, 'Standard', 3, 0, -1)

	select @UserID = UserID
	 from tblUser
	  where EmailAddress = @EmailAddress
	 										
end try
begin catch
	set @HostInfo = @HostInfo + '<Err>' + ISNULL(@ErrMsg,'') + '</Err>'

	exec @ret = master.dbo.upGetErrorInfo
end catch	
--log the action
insert tblActionLog(ActionTypeID, ActionData, UserID,LogDate)
	values(6,@HostInfo,@UserID,GETDATE())

SELECT @ret  --buble up to SqlHelper.ExecuteScalar
RETURN @ret
/*
exec spWebResetUserPWD
		@EmailAddress	= 'nam.hong@ingenico.com',
		@NewPWDText		= 'test101',
		@NewPassword	= 0x08637BA2941A368AFCF72FABF79F4C2D,
		@HostInfo = 'ip:12.24.3.5'

select * from tbluser
update tbluser
set EmailAddress = 'aus_camsdevmelb@ingenico.com',
IsActive = 1
where userid = 200711

select top 30 * from tblActionLog
order by LogID desc

*/


