USE [WebCAMS]
GO
/****** Object:  StoredProcedure [dbo].[spToolLoginGeoAnalysis]    Script Date: 18/06/20 14:47:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
alter proc [dbo].[spToolLoginGeoAnalysis] (
	@date date = null
)
as
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 4/08/14 11:58 $-->
--<!--$$Logfile: /SQL/Tool/spToolLoginGeoAnalysis.sql $-->
--<!--$$NoKeywords: $-->
declare @i int,
	@ip varchar(500),
	@GeoLocation varchar(2000)

set nocount on

--init
if @date is null
begin
	select @date = DATEADD(day,-1,getdate())
end

---################################################
---Append new IP from latest web action log
---################################################
select IP=dbo.fnGetXMLValue(ActionData, 'IP'),
		QTY=COUNT(*),
		AddedDate = MIN(LogDate)
	into #IP
	from tblActionLog with (nolock)
	where LogDate >= @date
	group by dbo.fnGetXMLValue(ActionData, 'IP')


delete from #IP
	where IP in (select IP from tblGeoIP)


--select * from #IP
--return

insert tblGeoIP (IP, Qty, AddedDate)
	select IP, Qty, AddedDate from #IP


---################################################
---Geo IP address via http://freegeoip.net/xml/
---################################################
set @i = 1
while @i<2000  --caped max of 2000
begin
	select top 1 @ip = ip
		from tblGeoIP
		where GeoLocation is null

	if @@ROWCOUNT >0
	 begin
		exec master.dbo.upGeoIP @IPAddress = @ip, @result = @GeoLocation output
		
		update tblGeoIP
			set GeoLocation = @GeoLocation,
				CountryCode = dbo.fnGetXMLValue(@GeoLocation, 'CountryCode'),
				Country = dbo.fnGetXMLValue(@GeoLocation, 'CountryName'),
				City = dbo.fnGetXMLValue(@GeoLocation, 'City')
			where ip = @ip

		set @i = @i + 1
	 end
	else
	 begin
		set @i = 2001
	 end
end

---################################################
---Analysis abnormal webcams user activities
---################################################
select *
	into #p
	from tblGeoIP with (nolock)
		where CountryCode not in ('AU', 'RD')

select ip = left(#p.ip, 20),
		CountryCode = left(#p.CountryCode, 5),
		Country = left(#p.Country, 10),
		City = left(#p.City, 10),
		ActionData = left(al.ActionData, 60),
		al.ActionTypeID,
		[User]= left(u.EmailAddress, 30)
	into #a
	from tblActionLog al with (nolock) join #p on dbo.fnGetXMLValue(ActionData, 'ip') = #p.ip
						join tblUser u with (nolock) on al.UserID = u.UserID
		where LogDate >= @date
				and ActionTypeID in (1,2,3,4)

--return results
select * from #a
	order by [User]


/*

spToolLoginGeoAnalysis

exec msdb.dbo.sp_send_dbmail
	@profile_name = 'SQLMail',
	@recipients = 'aus_camsdevmelb@ingenico.com',
	@importance = 'High',
	@subject = 'WebCAMS User Overseas Access',
	@body = 'Please see attached for the report.',
	@body_format = 'HTML',
	@query = 'EXEC WebCAMS.dbo.spToolLoginGeoAnalysis',
	@attach_query_result_as_file = 1,
	@exclude_query_output = 1


*/
GO
