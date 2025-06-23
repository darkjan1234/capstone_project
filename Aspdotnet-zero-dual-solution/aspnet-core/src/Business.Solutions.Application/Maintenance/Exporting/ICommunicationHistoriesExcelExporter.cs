using System.Collections.Generic;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;

namespace Business.Solutions.Maintenance.Exporting
{
    public interface ICommunicationHistoriesExcelExporter
    {
        FileDto ExportToFile(List<GetCommunicationHistoryForViewDto> communicationHistories);
    }
}