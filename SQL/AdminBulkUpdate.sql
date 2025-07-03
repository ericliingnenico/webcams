use webcams
go

if not exists(select 1 from tblModule where ModuleName = 'AdminBulkUpdate')
	insert tblModule values('AdminBulkUpdate', 'Bulk Update Tool',1)


insert tbluserModule
 select userid, 5
  from tbluser 
  where EmailAddress in ('dev101','MC157@FSP', 'NH72','JS329@admin')


--select * from tblModule

--sp_help tbluserModule


--select * from tbluser 
--where EmailAddress like 'js%'



--select * from tblUserModule
-- where userid = 202920
