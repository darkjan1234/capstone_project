using System;
using Abp.Application.Services.Dto;

namespace Business.Solutions.Maintenance.Dtos
{
    public class PTTMessageDto : EntityDto<Guid>
    {
        public int SenderId { get; set; }

        public int ReceiverId { get; set; }

        public int GroupId { get; set; }

        public string AudioPath { get; set; }

        public int DurationSeconds { get; set; }

    }
}