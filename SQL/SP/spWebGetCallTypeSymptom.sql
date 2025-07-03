Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetCallTypeSymptom]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetCallTypeSymptom]
GO


Create Procedure dbo.spWebGetCallTypeSymptom 
	(
		@UserID int,
		@CallTypeID int
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/10/12 11:29 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetCallTypeSymptom.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS and filter out Addtional Service (SymptomID = 800)
*/
 SET NOCOUNT ON

 CREATE TABLE #tmpSymptom (Symptom varchar(50) collate database_default, SymptomID int)

 --validate user
 IF EXISTS(SELECT 1 FROM tblUser WHERE UserID = @UserID AND IsActive = 1)
  BEGIN
 	INSERT INTO #tmpSymptom EXEC Cams.dbo.spGetCallTypeSymptom @CallTypeID = @CallTypeID
	--more selection, add empty one as default
 	if @@ROWCOUNT > 1
 	 begin
 		insert #tmpSymptom (Symptom, SymptomID) 
 			values ('',0)
 	 end

  END


  --return
  SELECT * 
	FROM #tmpSymptom 
	WHERE SymptomID <> 800
	ORDER BY Symptom
/*
spWebGetCallTypeSymptom 199635, 99
spWebGetCallTypeSymptom 1, '1999100057E'
sp_help calls

select * from calls


*/
Go

Grant EXEC on spWebGetCallTypeSymptom to eCAMS_Role
Go

Use CAMS
Go

Grant EXEC on spGetCallTypeSymptom to eCAMS_Role
Go




