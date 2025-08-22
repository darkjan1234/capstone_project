using System;
using Abp.Application.Services.Dto;

namespace Business.Solutions.Maintenance.Dtos
{
    public class PPODto : EntityDto<Guid>
    {
        public string ProvincialName { get; set; }

        public bool isActive { get; set; }

    }
}