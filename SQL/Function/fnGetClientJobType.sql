USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetClientJobType]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetClientJobType]
GO

CREATE FUNCTION dbo.fnGetClientJobType(
	@ClientID varchar(3),
	@JobTypeID tinyint
) RETURNS varchar(15)
--'<!--$$Revision: 1 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 8/11/10 9:16 $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnGetClientJobType.sql $-->
--'<!--$$NoKeywords: $-->
/*
 Purpose: Get Customised Client JobType
 @JobTypeID: 1-Install, 2-Deinstall, 3-upgrade, 4-swap
*/
AS
BEGIN
 declare @JobType varchar(15)
 select @JobType = JobType
	from tblJobType
	where LanguageID = 1 and JobTypeID = @JobTypeID

 if @ClientID = 'CTX' and @JobTypeID = 4
  begin
	select @JobType = 'CALL'
  end

 if @ClientID = 'CBA' and @JobTypeID = 4
  begin
	select @JobType = 'REPLACEMENT'
  end

 if @ClientID = 'CBA' and @JobTypeID = 2
  begin
	select @JobType = 'RECOVERY'
  end


 RETURN @JobType
END

/*
 select dbo.fnGetClientJobType ('NAB', 4)
 select dbo.fnGetClientJobType ('CTX', 4)
 select dbo.fnGetClientJobType ('CBA', 4)
 select dbo.fnGetClientJobType ('CBA', 2)
 
 

*/

Go

