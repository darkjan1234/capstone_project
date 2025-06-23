using System;
using Abp.Application.Services.Dto;
using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetGroupMemberForEditOutput
    {
        public CreateOrEditGroupMemberDto GroupMember { get; set; }

    }
}