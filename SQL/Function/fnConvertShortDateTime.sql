use CAMS
go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnConvertShortDateTime]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnConvertShortDateTime]
GO

create function dbo.fnConvertShortDateTime(@TheDate DateTime)
Returns varchar(11) as
begin
--Purpose: Convert to short date time dd/mm HH:MM
 declare @dd varchar(2),
	@mm varchar(2),
	@hh varchar(2),
	@mi varchar(2)
 --get all the parts
 select @dd = cast(DatePart(dd, @TheDate) as varchar(2)),
	@mm = cast(DatePart(mm, @TheDate) as varchar(2)),
	@hh = cast(DatePart(hh, @TheDate) as varchar(2)),
	@mi = cast(DatePart(mi, @TheDate) as varchar(2))

 --left pad with zero if needs
 select @dd = replicate('0', 2 - len(@dd)) + @dd,
	@mm = replicate('0', 2 - len(@mm)) + @mm,
	@hh = replicate('0', 2 - len(@hh)) + @hh,
	@mi = replicate('0', 2 - len(@mi)) + @mi

 --return
 return @dd + '/' + @mm + ' ' + @hh + ':' + @mi

end 

/*
select dbo.fnConvertShortDateTime('2004-06-07 12:13:14')

select dbo.fnConvertShortDateTime('2004-06-07 02:03:04')

*/
Go


