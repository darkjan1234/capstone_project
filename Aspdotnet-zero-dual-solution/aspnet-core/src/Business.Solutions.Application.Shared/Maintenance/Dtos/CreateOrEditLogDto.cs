using System;
using Abp.Application.Services.Dto;
using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Maintenance.Dtos
{
    public class CreateOrEditLogDto : EntityDto<Guid?>
    {

        public int UserId { get; set; }

        public string Activity { get; set; }

        public string LogLevel { get; set; }

    }
}