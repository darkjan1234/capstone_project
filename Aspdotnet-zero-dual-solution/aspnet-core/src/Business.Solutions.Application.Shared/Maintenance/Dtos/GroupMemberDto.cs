using System;
using Abp.Application.Services.Dto;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GroupMemberDto : EntityDto<Guid>
    {
        public int GroupId { get; set; }

        public string PttUserId { get; set; }

        public string RoleInGroup { get; set; }

    }
}