using Abp.Application.Services.Dto;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetAllForLookupTableInput : PagedAndSortedResultRequestDto
    {
        public string Filter { get; set; }
    }
}