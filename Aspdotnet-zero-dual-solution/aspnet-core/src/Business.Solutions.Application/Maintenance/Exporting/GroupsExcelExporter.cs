using System.Collections.Generic;
using Abp.Runtime.Session;
using Abp.Timing.Timezone;
using Business.Solutions.DataExporting.Excel.MiniExcel;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;
using Business.Solutions.Storage;

namespace Business.Solutions.Maintenance.Exporting
{
    public class GroupsExcelExporter : MiniExcelExcelExporterBase, IGroupsExcelExporter
    {

        private readonly ITimeZoneConverter _timeZoneConverter;
        private readonly IAbpSession _abpSession;

        public GroupsExcelExporter(
            ITimeZoneConverter timeZoneConverter,
            IAbpSession abpSession,
            ITempFileCacheManager tempFileCacheManager) :
    base(tempFileCacheManager)
        {
            _timeZoneConverter = timeZoneConverter;
            _abpSession = abpSession;
        }

        public FileDto ExportToFile(List<GetGroupForViewDto> groups)
        {

            var items = new List<Dictionary<string, object>>();

            foreach (var group in groups)
            {
                items.Add(new Dictionary<string, object>()
                    {
                        {L("Name"), group.Group.Name},

                    });
            }

            return CreateExcelPackage("GroupsList.xlsx", items);

        }
    }
}