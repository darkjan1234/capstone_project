using System.Collections.Generic;
using Abp.Runtime.Session;
using Abp.Timing.Timezone;
using Business.Solutions.DataExporting.Excel.MiniExcel;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;
using Business.Solutions.Storage;

namespace Business.Solutions.Maintenance.Exporting
{
    public class GroupMembersExcelExporter : MiniExcelExcelExporterBase, IGroupMembersExcelExporter
    {

        private readonly ITimeZoneConverter _timeZoneConverter;
        private readonly IAbpSession _abpSession;

        public GroupMembersExcelExporter(
            ITimeZoneConverter timeZoneConverter,
            IAbpSession abpSession,
            ITempFileCacheManager tempFileCacheManager) :
    base(tempFileCacheManager)
        {
            _timeZoneConverter = timeZoneConverter;
            _abpSession = abpSession;
        }

        public FileDto ExportToFile(List<GetGroupMemberForViewDto> groupMembers)
        {

            var items = new List<Dictionary<string, object>>();

            foreach (var groupMember in groupMembers)
            {
                items.Add(new Dictionary<string, object>()
                    {
                        {L("GroupId"), groupMember.GroupMember.GroupId},
                        {L("PttUserId"), groupMember.GroupMember.PttUserId},
                        {L("RoleInGroup"), groupMember.GroupMember.RoleInGroup},

                    });
            }

            return CreateExcelPackage("GroupMembersList.xlsx", items);

        }
    }
}