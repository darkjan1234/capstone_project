using System.Collections.Generic;
using Abp.Runtime.Session;
using Abp.Timing.Timezone;
using Business.Solutions.DataExporting.Excel.MiniExcel;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;
using Business.Solutions.Storage;

namespace Business.Solutions.Maintenance.Exporting
{
    public class LogsExcelExporter : MiniExcelExcelExporterBase, ILogsExcelExporter
    {

        private readonly ITimeZoneConverter _timeZoneConverter;
        private readonly IAbpSession _abpSession;

        public LogsExcelExporter(
            ITimeZoneConverter timeZoneConverter,
            IAbpSession abpSession,
            ITempFileCacheManager tempFileCacheManager) :
    base(tempFileCacheManager)
        {
            _timeZoneConverter = timeZoneConverter;
            _abpSession = abpSession;
        }

        public FileDto ExportToFile(List<GetLogForViewDto> logs)
        {

            var items = new List<Dictionary<string, object>>();

            foreach (var log in logs)
            {
                items.Add(new Dictionary<string, object>()
                    {
                        {L("UserId"), log.Log.UserId},
                        {L("Activity"), log.Log.Activity},
                        {L("LogLevel"), log.Log.LogLevel},

                    });
            }

            return CreateExcelPackage("LogsList.xlsx", items);

        }
    }
}