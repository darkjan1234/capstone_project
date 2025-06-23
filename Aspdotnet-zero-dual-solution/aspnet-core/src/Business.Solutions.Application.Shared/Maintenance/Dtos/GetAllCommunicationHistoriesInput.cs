using Abp.Application.Services.Dto;
using System;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetAllCommunicationHistoriesInput : PagedAndSortedResultRequestDto
    {
        public string Filter { get; set; }

        public int? MaxUserIdFilter { get; set; }
        public int? MinUserIdFilter { get; set; }

        public string ActionFilter { get; set; }

        public int? MaxReferenceIdFilter { get; set; }
        public int? MinReferenceIdFilter { get; set; }

    }
}