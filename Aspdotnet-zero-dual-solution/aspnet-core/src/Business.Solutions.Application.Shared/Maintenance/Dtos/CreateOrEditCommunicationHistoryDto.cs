using System;
using Abp.Application.Services.Dto;
using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Maintenance.Dtos
{
    public class CreateOrEditCommunicationHistoryDto : EntityDto<Guid?>
    {

        public int UserId { get; set; }

        [Required]
        public string Action { get; set; }

        public int ReferenceId { get; set; }

    }
}