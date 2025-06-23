using System.Collections.Generic;
using Abp.Runtime.Session;
using Abp.Timing.Timezone;
using Business.Solutions.DataExporting.Excel.MiniExcel;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;
using Business.Solutions.Storage;

namespace Business.Solutions.Maintenance.Exporting
{
    public class PTTMessagesExcelExporter : MiniExcelExcelExporterBase, IPTTMessagesExcelExporter
    {

        private readonly ITimeZoneConverter _timeZoneConverter;
        private readonly IAbpSession _abpSession;

        public PTTMessagesExcelExporter(
            ITimeZoneConverter timeZoneConverter,
            IAbpSession abpSession,
            ITempFileCacheManager tempFileCacheManager) :
    base(tempFileCacheManager)
        {
            _timeZoneConverter = timeZoneConverter;
            _abpSession = abpSession;
        }

        public FileDto ExportToFile(List<GetPTTMessageForViewDto> pttMessages)
        {

            var items = new List<Dictionary<string, object>>();

            foreach (var pttMessage in pttMessages)
            {
                items.Add(new Dictionary<string, object>()
                    {
                        {L("SenderId"), pttMessage.PTTMessage.SenderId},
                        {L("ReceiverId"), pttMessage.PTTMessage.ReceiverId},
                        {L("GroupId"), pttMessage.PTTMessage.GroupId},
                        {L("AudioPath"), pttMessage.PTTMessage.AudioPath},
                        {L("DurationSeconds"), pttMessage.PTTMessage.DurationSeconds},

                    });
            }

            return CreateExcelPackage("PTTMessagesList.xlsx", items);

        }
    }
}