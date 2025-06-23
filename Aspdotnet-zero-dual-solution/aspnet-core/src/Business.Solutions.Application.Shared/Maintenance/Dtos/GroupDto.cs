using System;
using Abp.Application.Services.Dto;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GroupDto : EntityDto<Guid>
    {
        public string Name { get; set; }

    }
}