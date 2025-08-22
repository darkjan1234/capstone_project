using Abp.Application.Services.Dto;
using System;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetAllPPOsForExcelInput
    {
        public string Filter { get; set; }

        public string ProvincialNameFilter { get; set; }

        public int? isActiveFilter { get; set; }

    }
}