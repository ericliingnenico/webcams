USE WebCAMS
GO

Alter PROCEDURE dbo.spWebGetMerchantAcceptance 
(
	@JobID	bigint,
	@UserID int
)
AS
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/11 16:43 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetMarchantAcceptance.sql $-->
--<!--$$NoKeywords: $-->

SET NOCOUNT ON

EXEC Cams.dbo.spWebGetMerchantAcceptance  @UserID = @UserID, @JobID = @JobID
Go

Grant EXEC on dbo.spWebGetMerchantAcceptance  to eCAMS_Role
Go


Use CAMS
Go

Alter PROCEDURE dbo.spWebGetMerchantAcceptance 
(
	@JobID	bigint,
	@UserID int
)
AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Thanh $-->
--<!--$$Date: 15/04/04 9:54a $-->
--<!--$$Logfile: /eReport/SQL/SP/spWebGetMerchantAcceptance.sql $-->
--<!--$$NoKeywords: $-->

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


DECLARE @InstallerID int

--get InstallerID
SELECT @InstallerID = InstallerID 
  FROM WebCAMS.dbo.tblUser 
 WHERE UserID = @UserID

if dbo.fnIsSwapCall(@JobID) = 1 
  begin
	if exists(select 1 from Calls where CallNumber = CAST(@JobID AS VARCHAR(11)) )
	 begin
		SELECT m.* 
		  FROM tblMerchantAcceptance m
				JOIN Calls c ON c.CallNumber = CAST(m.JobID AS VARCHAR(11)) 
				JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON l.Location = c.AssignedTo
				WHERE  m.JobID = @JobID
	 end
	else
	 begin
	  -- Get Call_History Record
		SELECT m.* 
		  FROM tblMerchantAcceptance m
				JOIN Call_History c ON c.CallNumber = CAST(m.JobID AS VARCHAR(11)) 
				JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON l.Location = c.AssignedTo
				WHERE  m.JobID = @JobID
	 end
  end 
else
  begin
	if exists(select 1 from IMS_Jobs where JobID = @JobID )
	 begin
		SELECT m.* 
		  FROM tblMerchantAcceptance m
			JOIN IMS_Jobs j ON j.JobID = m.JobID 
			JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON l.Location = j.BookedInstaller
			WHERE  m.JobID = @JobID
	 end
	else
	 begin
		-- Get Job History Record
		SELECT m.* 
		  FROM tblMerchantAcceptance m
			JOIN IMS_Jobs_History j ON j.JobID = m.JobID 
			JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON l.Location = j.BookedInstaller
			WHERE  m.JobID = @JobID
	 end
  end

/*
EXEC spWebGetMerchantAcceptance 20040208752,199525
EXEC spWebGetMerchantAcceptance 229056,199525
*/
GO

Grant EXEC on dbo.spWebGetMerchantAcceptance  to eCAMS_Role
Go
