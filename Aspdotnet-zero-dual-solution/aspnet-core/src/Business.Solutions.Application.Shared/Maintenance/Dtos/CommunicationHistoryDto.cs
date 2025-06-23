using System;
using Abp.Application.Services.Dto;

namespace Business.Solutions.Maintenance.Dtos
{
    public class CommunicationHistoryDto : EntityDto<Guid>
    {
        public int UserId { get; set; }

        public string Action { get; set; }

        public int ReferenceId { get; set; }

    }
}