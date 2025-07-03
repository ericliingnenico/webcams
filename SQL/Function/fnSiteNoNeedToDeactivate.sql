USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnSiteNoNeedToDeactivate]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnSiteNoNeedToDeactivate]
GO

CREATE FUNCTION dbo.fnSiteNoNeedToDeactivate(
	@ClientID varchar(3),
	@TerminalID varchar(20)
) RETURNS bit
--'<!--$$Revision: 3 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 27/11/10 11:22 $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnSiteNoNeedToDeactivate.sql $-->
--'<!--$$NoKeywords: $-->
/*
 Purpose: Check if the site need to be deactivated
 example: CBA Branch Pickup reciovery, site reused for the pickup, so at closure, no need to deactivate
*/
AS
BEGIN
 declare @ret bit
 set @ret = 0


 if @ClientID = 'CBA' and (@TerminalID like '[0-9][0-9][0-9]-[0-9][0-9][0-9]' or @TerminalID ='RECOVERY' or @TerminalID ='ADDITIONAL SVR')
  begin
	select @ret = 1
  end

 RETURN @ret
END

/*
 select dbo.fnSiteNoNeedToDeactivate ('NAB', 1234556)
 select dbo.fnSiteNoNeedToDeactivate ('CBA', '062-414')
 select dbo.fnSiteNoNeedToDeactivate ('CBA', 'recovery')
 
 

*/

Go

