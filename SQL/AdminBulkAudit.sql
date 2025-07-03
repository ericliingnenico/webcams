use cams
go


alter table tblAuditLog
	alter column AuditData varchar(max)
Go

insert tblAuditObject values('WebAdminBulkUpdate')
Go
