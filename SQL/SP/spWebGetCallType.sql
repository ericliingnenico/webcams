Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetCallType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetCallType]
GO


Create Procedure dbo.spWebGetCallType 
	(
		@UserID int,
		@EquipmentCode varchar(2)
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/10/12 11:29 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetCallType.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON

 create table #tmpCallType(
	CallType varchar(50) collate database_default,
	EquipmentCode varchar(2) collate database_default,
	CallTypeID int)
	
 --validate user
 IF EXISTS(SELECT 1 FROM tblUser WHERE UserID = @UserID AND IsActive = 1)
  BEGIN
 	insert #tmpCallType EXEC Cams.dbo.spGetCallType @EquipmentCode = @EquipmentCode
 	--more selection, add empty one as default
 	if @@ROWCOUNT > 1
 	 begin
 		insert #tmpCallType (CallType,EquipmentCode,CallTypeID) 
 			values ('',@EquipmentCode,0)
 	 end
 	 select * from #tmpCallType order by CallType
 	 
  END
/*
exec spWebGetCallType @UserID=200694,@EquipmentCode='C5'

exec spWebGetCallType @UserID=200694,@EquipmentCode='UW'


*/
Go

Grant EXEC on spWebGetCallType to eCAMS_Role
Go





