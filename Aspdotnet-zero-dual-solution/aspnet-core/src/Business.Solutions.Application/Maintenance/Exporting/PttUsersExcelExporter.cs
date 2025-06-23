using System.Collections.Generic;
using Abp.Runtime.Session;
using Abp.Timing.Timezone;
using Business.Solutions.DataExporting.Excel.MiniExcel;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;
using Business.Solutions.Storage;

namespace Business.Solutions.Maintenance.Exporting
{
    public class PttUsersExcelExporter : MiniExcelExcelExporterBase, IPttUsersExcelExporter
    {

        private readonly ITimeZoneConverter _timeZoneConverter;
        private readonly IAbpSession _abpSession;

        public PttUsersExcelExporter(
            ITimeZoneConverter timeZoneConverter,
            IAbpSession abpSession,
            ITempFileCacheManager tempFileCacheManager) :
    base(tempFileCacheManager)
        {
            _timeZoneConverter = timeZoneConverter;
            _abpSession = abpSession;
        }

        public FileDto ExportToFile(List<GetPttUserForViewDto> pttUsers)
        {

            var items = new List<Dictionary<string, object>>();

            foreach (var pttUser in pttUsers)
            {
                items.Add(new Dictionary<string, object>()
                    {
                        {L("FullName"), pttUser.PttUser.FullName},
                        {L("Email"), pttUser.PttUser.Email},
                        {L("PasswordHash"), pttUser.PttUser.PasswordHash},
                        {L("Role"), pttUser.PttUser.Role},
                        {L("Status"), pttUser.PttUser.Status},

                    });
            }

            return CreateExcelPackage("PttUsersList.xlsx", items);

        }
    }
}