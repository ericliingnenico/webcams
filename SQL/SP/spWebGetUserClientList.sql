Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetUserClientList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetUserClientList]
GO



Create Procedure dbo.spWebGetUserClientList 
	(
		@UserID		int
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/08/08 10:59a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetUserClientList.sql $-->
--<!--$$NoKeywords: $-->

 SELECT UserID, ClientID, MIN(DisplayOrder) as DisplayOrder
   FROM tblUserClientDeviceType
  WHERE UserID = @UserID 
  GROUP BY UserID, ClientID
  ORDER BY DisplayOrder

/*

exec spWebGetUserClientList 199587

update tblUserClientDeviceType
 set DisplayOrder = 2
 where USerID = 199587 and ClientID ='HIC'

*/

GO


Grant EXEC on spWebGetUserClientList to eCAMS_Role
Go
