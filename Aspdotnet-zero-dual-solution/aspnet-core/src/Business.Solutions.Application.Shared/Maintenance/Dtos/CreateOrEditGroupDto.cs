using System;
using Abp.Application.Services.Dto;
using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Maintenance.Dtos
{
    public class CreateOrEditGroupDto : EntityDto<Guid?>
    {

        [Required]
        public string Name { get; set; }

    }
}