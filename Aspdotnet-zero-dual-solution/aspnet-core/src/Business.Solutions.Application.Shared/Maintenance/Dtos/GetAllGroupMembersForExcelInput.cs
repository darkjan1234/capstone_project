using Abp.Application.Services.Dto;
using System;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetAllGroupMembersForExcelInput
    {
        public string Filter { get; set; }

        public int? MaxGroupIdFilter { get; set; }
        public int? MinGroupIdFilter { get; set; }

        public string PttUserIdFilter { get; set; }

        public string RoleInGroupFilter { get; set; }

    }
}