Use CAMS
Go

Alter Procedure dbo.spWebGetSiteList 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20) = NULL,
		@MerchantID varchar(16) = NULL,
		@Name varchar(50) = NULL,
		@City varchar(30) = NULL,
		@Postcode varchar(10) = NULL
	)
	AS
--<!--$$Revision: 30 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 8/11/10 8:51 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSiteList.sql $-->
--<!--$$NoKeywords: $-->

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 SELECT s.ClientID, 
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + s.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
	MerchantID as MerchantID, 
	[Name] as MerchantName,
	City as Suburb, 
	Postcode,
	--Not expose to other clients instead of BoQ-- '<A HREF="../Member/Merchant.aspx?CID=' + s.ClientID + '&TID=' + TerminalID + '">Edit</A>' as Edit,  
	'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + s.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment,
	'<A HREF="../Member/TerminalList.aspx?CID=' + s.ClientID + '&TID=' + TerminalID + '">View</A>' as Jobs
/*
,
	'<A HREF="#" onclick="javascript:popupwindow(''http://services.keycorp.net/GeoMap/GMap.aspx?Latitude=' + cast(s.Latitude as varchar) 
												+ '&Longitude=' + cast(s.Longitude as varchar)
												+ '&Text=' + s.Name 
												+ '&dc=0&rd=0'')">Map</A>' as Map
*/	
	FROM Sites s JOIN WebCams.dbo.tblUserClientDeviceType u ON s.ClientID = u.ClientID 
															AND isnull(s.DeviceType, '') = ISNULL(u.DeviceType, isnull(s.DeviceType, ''))
															AND u.ClientID = @ClientID 
															AND u.UserID = @UserID 
	WHERE TerminalID = ISNULL(@TerminalID, TerminalID) AND
		MerchantID = ISNULL(@MerchantID, MerchantID) AND	
		Name LIKE ISNULL(@Name, Name)  AND	
		City = ISNULL(@City, City) AND	
		Postcode = ISNULL(@Postcode, Postcode)

UNION 
 SELECT j.ClientID, 
	TerminalID as TerminalID,
	MerchantID, 
	[Name] as MerchantName,
	City as Suburb, 
	Postcode,
		--Not expose to other clients instead of BoQ-- '' as Edit,
	'' as SiteEquipment,
	'<A HREF="../Member/TerminalList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>' as Jobs
/*
,
	'<A HREF="#" onclick="javascript:popupwindow(''http://services.keycorp.net/GeoMap/GMap.aspx?Latitude=' + cast(j.Latitude as varchar) 
												+ '&Longitude=' + cast(j.Longitude as varchar)
												+ '&Text=' + j.Name 
												+ '&dc=0&rd=0'')">Map</A>' as Map
*/
	FROM IMS_Jobs j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID 
															AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
															AND u.ClientID = @ClientID 
															AND u.UserID = @UserID 
	WHERE j.JobTypeID = 1  AND 
		TerminalID = ISNULL(@TerminalID, TerminalID) AND
		MerchantID = ISNULL(@MerchantID, MerchantID) AND	
		Name LIKE  ISNULL(@Name, Name)  AND	
		City = ISNULL(@City, City) AND	
		Postcode = ISNULL(@Postcode, Postcode)

Order By MerchantName

--Return
RETURN @@ERROR

GO

Grant EXEC on spWebGetSiteList to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebGetSiteList 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20) = NULL,
		@MerchantID varchar(16) = NULL,
		@Name varchar(50) = NULL,
		@City varchar(30) = NULL,
		@Postcode varchar(10) = NULL
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 24/03/04 9:28a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSiteList.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC CAMS.dbo.spWebGetSiteList @UserID = @UserID, @ClientID = @ClientID, @TerminalID = @TerminalID,
				@MerchantID = @MerchantID, @Name = @Name, @City = @City, @Postcode = @Postcode

/*
spWebGetSiteList 2, 'wbc', '21999853'
*/
Go

Grant EXEC on spWebGetSiteList to eCAMS_Role
Go




