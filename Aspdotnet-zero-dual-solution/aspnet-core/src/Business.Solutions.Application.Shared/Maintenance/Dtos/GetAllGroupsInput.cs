using Abp.Application.Services.Dto;
using System;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetAllGroupsInput : PagedAndSortedResultRequestDto
    {
        public string Filter { get; set; }

        public string NameFilter { get; set; }

    }
}