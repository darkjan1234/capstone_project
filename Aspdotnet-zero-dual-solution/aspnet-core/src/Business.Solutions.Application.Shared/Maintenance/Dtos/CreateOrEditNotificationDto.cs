using System;
using Abp.Application.Services.Dto;
using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Maintenance.Dtos
{
    public class CreateOrEditNotificationDto : EntityDto<Guid?>
    {

        public int UserId { get; set; }

        public string Message { get; set; }

        public bool Isread { get; set; }

    }
}