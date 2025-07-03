Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPCall 
	(
		@UserID int,
		@CallNumber varchar(11)
	)
	AS
--<!--$$Revision: 15 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 13/12/06 8:30a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPCall.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPCall @UserID = @UserID, @CallNumber = @CallNumber
GO

Grant EXEC on spWebGetFSPCall to eCAMS_Role
Go

Use CAMS
Go

ALTER PROCEDURE dbo.spWebGetFSPCall 
	(
		@UserID int,
		@CallNumber varchar(11)
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 2/04/03 17:01 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetFSPCall.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON

 DECLARE @InstallerID int

 --get installer id form webcams
 SELECT @InstallerID = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID
 
 IF EXISTS(SELECT 1 FROM vwCalls c JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON c.AssignedTo = l.Location
			WHERE CallNumber = @CallNumber)
  BEGIN
/*
--this is used by mCAMS

	 SELECT 'OPEN' AS Source,
		CallNumber,
		c.ClientID,
		TerminalID,
		[Name],
		Address,
		Address2,
		City,
		Postcode,
		State,
		Caller as Contact,
		ISNULL(CallerPhone, '') as Phone,
		Calltype,
		Symptom,
		Fault,
		Severity,
		FaultMemo,
		NewSerial1,
		NewMaker1,
		NewModel1,
		NewDevice1,
		OldSerial1,
		OldMaker1,
		OldModel1,
		OldDevice1,
		NewSerial2,
		NewMaker2,
		NewModel2,
		NewDevice2,
		OldSerial2,
		OldMaker2,
		OldModel2,
		OldDevice2,
		NewSerial3,
		NewMaker3,
		NewModel3,
		NewDevice3,
		OldSerial3,
		OldMaker3,
		OldModel3,
		OldDevice3,
		NewSerial4,
		NewMaker4,
		NewModel4,
		NewDevice4,
		OldSerial4,
		OldMaker4,
		OldModel4,
		OldDevice4,
		NewSerial5,
		NewMaker5,
		NewModel5,
		NewDevice5,
		OldSerial5,
		OldMaker5,
		OldModel5,
		OldDevice5,
	     	dbo.fnFormatDateTime(CAST(Convert(varchar, RequiredDate, 107) + ' ' + convert(varchar, RequiredTime, 108) as datetime)) AS RequiredDateTime		
		FROM Call_Faxes c JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON c.AssignedTo = l.Location
		WHERE CallNumber = @CallNumber
*/
	 SELECT 'OPEN' AS Source,
	     	c.*
		FROM vwCalls c JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON c.AssignedTo = l.Location
		WHERE CallNumber = @CallNumber

  END

 ELSE
  BEGIN
	 SELECT 'CLOSED' AS Source,
		c.*
		FROM vwCallsHistory c JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON c.AssignedTo = l.Location
		WHERE CallNumber = @CallNumber
  END

/*
spWebGetFSPCall 199512, '20040401700'
spWebGetFSPCall 199512, '1999100057E'
*/

GO
Grant EXEC on spWebGetFSPCall to eCAMS_Role
Go

