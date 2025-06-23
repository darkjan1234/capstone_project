using System.Collections.Generic;
using Business.Solutions.Auditing.Dto;
using Business.Solutions.Dto;

namespace Business.Solutions.Auditing.Exporting
{
    public interface IAuditLogListExcelExporter
    {
        FileDto ExportToFile(List<AuditLogListDto> auditLogListDtos);

        FileDto ExportToFile(List<EntityChangeListDto> entityChangeListDtos);
    }
}
