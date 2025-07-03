USE CAMS
Go

if object_id('spWebGetSiteListNG') is null
	exec ('create procedure dbo.spWebGetSiteListNG as return 1')
go



Alter Procedure dbo.spWebGetSiteListNG 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20) = NULL,
		@MerchantID varchar(16) = NULL,
		@Name varchar(50) = NULL,
		@City varchar(50) = NULL,
		@Postcode varchar(10) = NULL
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/09/15 11:10 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSiteListNG.sql $-->
--<!--$$NoKeywords: $-->

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 
 if  @Name is not null
  begin
	select @Name = '%' + @Name + '%'
  end

 SELECT s.ClientID, 
	s.TerminalID,
	s.MerchantID, 
	s.[Name],
	s.Address,
	s.Address2,
	s.City, 
	s.Postcode,
	s.State,
	s.DeviceType
	FROM Sites s JOIN UserClientDeviceType u ON s.ClientID = u.ClientID 
															AND isnull(s.DeviceType, '') = ISNULL(u.DeviceType, isnull(s.DeviceType, ''))
															AND u.ClientID = @ClientID 
															AND u.UserID = @UserID 
	WHERE TerminalID = ISNULL(@TerminalID, TerminalID) AND
		MerchantID = ISNULL(@MerchantID, MerchantID) AND	
		Name LIKE ISNULL(@Name, Name)  AND	
		City = ISNULL(@City, City) AND	
		Postcode = ISNULL(@Postcode, Postcode)


--Return
RETURN @@ERROR

GO

Grant EXEC on spWebGetSiteListNG to eCAMS_Role
Go


/*

exec spWebGetSiteListNG @UserID=210002,@ClientID='SUN',@TerminalID=NULL,@MerchantID=NULL,@Name='cafe',@City=NULL,@Postcode='3000'

*/
Go
