using System;
using Abp.Application.Services.Dto;
using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetPttUserForEditOutput
    {
        public CreateOrEditPttUserDto PttUser { get; set; }

    }
}