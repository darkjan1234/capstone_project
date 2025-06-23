using System.Collections.Generic;
using Abp.Runtime.Session;
using Abp.Timing.Timezone;
using Business.Solutions.DataExporting.Excel.MiniExcel;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;
using Business.Solutions.Storage;

namespace Business.Solutions.Maintenance.Exporting
{
    public class NotificationsExcelExporter : MiniExcelExcelExporterBase, INotificationsExcelExporter
    {

        private readonly ITimeZoneConverter _timeZoneConverter;
        private readonly IAbpSession _abpSession;

        public NotificationsExcelExporter(
            ITimeZoneConverter timeZoneConverter,
            IAbpSession abpSession,
            ITempFileCacheManager tempFileCacheManager) :
    base(tempFileCacheManager)
        {
            _timeZoneConverter = timeZoneConverter;
            _abpSession = abpSession;
        }

        public FileDto ExportToFile(List<GetNotificationForViewDto> notifications)
        {

            var items = new List<Dictionary<string, object>>();

            foreach (var notification in notifications)
            {
                items.Add(new Dictionary<string, object>()
                    {
                        {L("UserId"), notification.Notification.UserId},
                        {L("Message"), notification.Notification.Message},
                        {L("Isread"), notification.Notification.Isread},

                    });
            }

            return CreateExcelPackage("NotificationsList.xlsx", items);

        }
    }
}