using System;
using Abp.Application.Services.Dto;

namespace Business.Solutions.Maintenance.Dtos
{
    public class LogDto : EntityDto<Guid>
    {
        public int UserId { get; set; }

        public string Activity { get; set; }

        public string LogLevel { get; set; }

    }
}