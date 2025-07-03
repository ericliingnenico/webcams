USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetCallJobType]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetCallJobType]
GO

CREATE FUNCTION dbo.fnGetCallJobType(
	@ClientID varchar(3)
) RETURNS varchar(5)
--'<!--$$Revision: 1 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 13/07/09 5:38p $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnGetCallJobType.sql $-->
--'<!--$$NoKeywords: $-->
/*
 Purpose: Retrieve JobNote according to the setup in webCAMS.dbo.tblControl ("ViewAllJobNote", "CTX,HIC")
          If the clientID is not in tblControl, just show xml value of '<WebJobNote>'
*/
AS
BEGIN
 RETURN CASE WHEN @ClientID = 'CTX' THEN 'CALL'
				ELSE 'SWAP'
			 END
END

/*
 select dbo.fnGetCallJobType ('NAB')
 select dbo.fnGetCallJobType ('CTX')

*/

Go

