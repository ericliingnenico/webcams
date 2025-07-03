Use CAMS
Go

ALter Procedure dbo.spWebGetFSPChildrenExt 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 11 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 7/09/05 3:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPChildrenExt.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: return FSP children list

Declare @InstallerID int

 SET NOCOUNT ON

 
 SELECT @InstallerID = InstallerID
   FROM WebCams.dbo.tblUser 
  WHERE UserID = @UserID

SELECT R.FSPID, R.FSPDisplayName, U.UserID FROM (
 SELECT l.Location as FSPID, 
	' ' + Cast(l.Location as varchar) + '-' + l.[Description] as FSPDisplayName
  FROM Locations_Master l WHERE @InstallerID = l.Location
 UNION
 SELECT l.Location as FSPID, 
	REPLICATE('---', f.[Level]) + Cast(l.Location as varchar) + '-' + ISNULL(l.Contact, 'TBA') as FSPDisplayName
  FROM Locations_Master l JOIN dbo.fnGetLocationTree(@InstallerID, 1) f ON l.Location = f.Location
) R
LEFT JOIN WebCAMS.dbo.tblUser U on U.EmailAddress = cast(R.FSPID as varchar)
ORDER BY R.FSPDisplayName


GO

Grant EXEC on spWebGetFSPChildrenExt to eCAMS_Role
Go


Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPChildrenExt 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 2:41p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPChildrenExt.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/

 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPChildrenExt @UserID = @UserID
/*
exec spWebGetFSPChildrenExt 199516


*/
GO

Grant EXEC on spWebGetFSPChildrenExt to eCAMS_Role
Go
