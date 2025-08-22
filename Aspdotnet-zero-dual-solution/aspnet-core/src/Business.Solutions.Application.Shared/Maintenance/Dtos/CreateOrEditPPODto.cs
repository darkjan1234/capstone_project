using System;
using Abp.Application.Services.Dto;
using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Maintenance.Dtos
{
    public class CreateOrEditPPODto : EntityDto<Guid?>
    {

        [Required]
        public string ProvincialName { get; set; }

        public bool isActive { get; set; }

    }
}