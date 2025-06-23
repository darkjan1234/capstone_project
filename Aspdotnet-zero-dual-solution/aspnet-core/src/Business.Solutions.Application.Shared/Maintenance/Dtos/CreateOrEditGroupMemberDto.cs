using System;
using Abp.Application.Services.Dto;
using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Maintenance.Dtos
{
    public class CreateOrEditGroupMemberDto : EntityDto<Guid?>
    {

        public int GroupId { get; set; }

        public string PttUserId { get; set; }

        [Required]
        public string RoleInGroup { get; set; }

    }
}