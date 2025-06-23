using Abp.Application.Services.Dto;

namespace Business.Solutions.Notifications.Dto
{
    public class GetAllForLookupTableInput : PagedAndSortedResultRequestDto
    {
        public string Filter { get; set; }
    }
}