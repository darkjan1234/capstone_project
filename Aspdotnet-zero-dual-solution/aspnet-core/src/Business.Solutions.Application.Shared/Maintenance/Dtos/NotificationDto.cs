using System;
using Abp.Application.Services.Dto;

namespace Business.Solutions.Maintenance.Dtos
{
    public class NotificationDto : EntityDto<Guid>
    {
        public int UserId { get; set; }

        public string Message { get; set; }

        public bool Isread { get; set; }

    }
}