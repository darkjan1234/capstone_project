using System.Collections.Generic;
using Abp.Runtime.Session;
using Abp.Timing.Timezone;
using Business.Solutions.DataExporting.Excel.MiniExcel;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;
using Business.Solutions.Storage;

namespace Business.Solutions.Maintenance.Exporting
{
    public class CommunicationHistoriesExcelExporter : MiniExcelExcelExporterBase, ICommunicationHistoriesExcelExporter
    {

        private readonly ITimeZoneConverter _timeZoneConverter;
        private readonly IAbpSession _abpSession;

        public CommunicationHistoriesExcelExporter(
            ITimeZoneConverter timeZoneConverter,
            IAbpSession abpSession,
            ITempFileCacheManager tempFileCacheManager) :
    base(tempFileCacheManager)
        {
            _timeZoneConverter = timeZoneConverter;
            _abpSession = abpSession;
        }

        public FileDto ExportToFile(List<GetCommunicationHistoryForViewDto> communicationHistories)
        {

            var items = new List<Dictionary<string, object>>();

            foreach (var communicationHistory in communicationHistories)
            {
                items.Add(new Dictionary<string, object>()
                    {
                        {L("UserId"), communicationHistory.CommunicationHistory.UserId},
                        {L("Action"), communicationHistory.CommunicationHistory.Action},
                        {L("ReferenceId"), communicationHistory.CommunicationHistory.ReferenceId},

                    });
            }

            return CreateExcelPackage("CommunicationHistoriesList.xlsx", items);

        }
    }
}