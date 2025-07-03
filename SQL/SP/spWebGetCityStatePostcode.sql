USE [CAMS]
GO

if object_id('spWebGetCityStatePostcode') is null
	exec ('create procedure dbo.spWebGetCityStatePostcode as return 1')
go


alter proc  spWebGetCityStatePostcode (
	@UserID int,
	@City varchar(20))
as
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 18/09/15 15:38 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetCityStatePostcode.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Retrieve device type
*/
 SET NOCOUNT ON
 select City, State, PostCode = min(PostCode) --, *
  from tblPostcode with (nolock)
  where City like @City + '%' and Category = 'Delivery Area' and IsActive = 1
  group by City, State
  order by City, State

/*
 spWebGetCityStatePostcode  1, 'moun'
 spWebGetCityStatePostcode  1, 'camber'

*/

Go




GRANT EXEC ON spWebGetCityStatePostcode TO eCAMS_Role
go


