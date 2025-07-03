USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetTradingHoursInfo]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetTradingHoursInfo]
GO

CREATE FUNCTION dbo.fnGetTradingHoursInfo(
		@TradingHoursMon	varchar(15),
		@TradingHoursTue	varchar(15),
		@TradingHoursWed	varchar(15),
		@TradingHoursThu	varchar(15),
		@TradingHoursFri	varchar(15),
		@TradingHoursSat 	varchar(15),
		@TradingHoursSun 	varchar(15)
) RETURNS varchar(200)
--'<!--$$Revision: 4 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 11/03/08 11:02a $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnGetTradingHoursInfo.sql $-->
--'<!--$$NoKeywords: $-->
/*
 Purpose: Combine TradingHours into one string
*/
AS
BEGIN
 DECLARE @TradingHoursInfo varchar(200),
	@pos int
 --init
 SELECT @TradingHoursInfo = ''
 --trim the spaces
 SELECT @TradingHoursMon = REPLACE(@TradingHoursMon, ' ', ''),
		@TradingHoursTue = REPLACE(@TradingHoursTue, ' ', ''),
		@TradingHoursWed = REPLACE(@TradingHoursWed, ' ', ''),
		@TradingHoursThu = REPLACE(@TradingHoursThu, ' ', ''),
		@TradingHoursFri = REPLACE(@TradingHoursFri, ' ', ''),
		@TradingHoursSat = REPLACE(@TradingHoursSat, ' ', ''),
		@TradingHoursSun = REPLACE(@TradingHoursSun, ' ', '')

/*
 SELECT @TradingHoursMon = ISNULL(@TradingHoursMon, 'CLOSED'),
		@TradingHoursTue = ISNULL(@TradingHoursTue, 'CLOSED'),
		@TradingHoursWed = ISNULL(@TradingHoursWed, 'CLOSED'),
		@TradingHoursThu = ISNULL(@TradingHoursThu, 'CLOSED'),
		@TradingHoursFri = ISNULL(@TradingHoursFri, 'CLOSED'),
		@TradingHoursSat = ISNULL(@TradingHoursSat, 'CLOSED'),
		@TradingHoursSun = ISNULL(@TradingHoursSun, 'CLOSED')
*/
 
--MF the same tradinghours
 IF @TradingHoursMon = @TradingHoursTue AND @TradingHoursMon = @TradingHoursWed AND @TradingHoursMon = @TradingHoursThu AND @TradingHoursMon = @TradingHoursFri
  BEGIN
	SELECT @TradingHoursInfo = @TradingHoursInfo + 'MF-' + @TradingHoursMon
  END
 ELSE
  BEGIN
	 IF LEN(@TradingHoursMon) > 0
	  BEGIN
		SELECT @TradingHoursInfo = @TradingHoursInfo + 'Mon-' + @TradingHoursMon
	  END
	 IF LEN(@TradingHoursTue) > 0
	  BEGIN
		SELECT @pos = CHARINDEX(@TradingHoursTue, @TradingHoursInfo)
		IF @pos>0
		 BEGIN
			SELECT @TradingHoursInfo = LEFT(@TradingHoursInfo, @pos-2) + '/Tue-' + RIGHT(@TradingHoursInfo, LEN(@TradingHoursInfo)-@pos+1)
         END
		ELSE
		 BEGIN
			SELECT @TradingHoursInfo = @TradingHoursInfo + ' Tue-' + @TradingHoursTue
         END
	  END
	 IF LEN(@TradingHoursWed) > 0
	  BEGIN
		SELECT @pos = CHARINDEX(@TradingHoursWed, @TradingHoursInfo)
		IF @pos>0
		 BEGIN
			SELECT @TradingHoursInfo = LEFT(@TradingHoursInfo, @pos-2) + '/Wed-' + RIGHT(@TradingHoursInfo, LEN(@TradingHoursInfo)-@pos+1)
         END
		ELSE
		 BEGIN
			SELECT @TradingHoursInfo = @TradingHoursInfo + ' Wed-' + @TradingHoursWed
         END
	  END
	 IF LEN(@TradingHoursThu) > 0
	  BEGIN
		SELECT @pos = CHARINDEX(@TradingHoursThu, @TradingHoursInfo)
		IF @pos>0
		 BEGIN
			SELECT @TradingHoursInfo = LEFT(@TradingHoursInfo, @pos-2) + '/Thu-' + RIGHT(@TradingHoursInfo, LEN(@TradingHoursInfo)-@pos+1)
         END
		ELSE
		 BEGIN
			SELECT @TradingHoursInfo = @TradingHoursInfo + ' Thu-' + @TradingHoursThu
         END
	  END
	 IF LEN(@TradingHoursFri) > 0
	  BEGIN
		SELECT @pos = CHARINDEX(@TradingHoursFri, @TradingHoursInfo)
		IF @pos>0
		 BEGIN
			SELECT @TradingHoursInfo = LEFT(@TradingHoursInfo, @pos-2) + '/Fri-' + RIGHT(@TradingHoursInfo, LEN(@TradingHoursInfo)-@pos+1)
         END
		ELSE
		 BEGIN
			SELECT @TradingHoursInfo = @TradingHoursInfo + ' Fri-' + @TradingHoursFri
         END
	  END
  END
 IF LEN(@TradingHoursSat) > 0
  BEGIN
	SELECT @TradingHoursInfo = @TradingHoursInfo + ' Sat-' + @TradingHoursSat
  END

 IF LEN(@TradingHoursSun) > 0
  BEGIN
	SELECT @TradingHoursInfo = @TradingHoursInfo + ' Sun-' + @TradingHoursSun
  END


 RETURN @TradingHoursInfo
END

/*
 select dbo.fnGetTradingHoursInfo ('0930-1630','0930-1630','0930-1630','0930-1630','0930-1630','1030-1430',null)
 select dbo.fnGetTradingHoursInfo ('0930-1630','0930-1630','0930-1630','0930-1630','0930-1630','1030-1430','12:30-15:30')
 select dbo.fnGetTradingHoursInfo ('0930-1630',Null,'0930-1630','0930-1630','0930-1630','1030-1430',null)
 select dbo.fnGetTradingHoursInfo (null, '0930-1630',Null,'0930-1630','0930-1630','1030-1430',null)
 select dbo.fnGetTradingHoursInfo ('0930-1630','0930-1631','0930-1630','0930-1630','0930-1631','1030-1430','12:30-15:30')
 select dbo.fnGetTradingHoursInfo (null, Null,'0930-1630','0930-1930','0930-1930','1030-1430',null)


*/

Go

