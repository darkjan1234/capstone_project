using System;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;

namespace Business.Solutions.Maintenance
{
    public interface INotificationsAppService : IApplicationService
    {
        Task<PagedResultDto<GetNotificationForViewDto>> GetAll(GetAllNotificationsInput input);

        Task<GetNotificationForViewDto> GetNotificationForView(Guid id);

        Task<GetNotificationForEditOutput> GetNotificationForEdit(EntityDto<Guid> input);

        Task CreateOrEdit(CreateOrEditNotificationDto input);

        Task Delete(EntityDto<Guid> input);

        Task<FileDto> GetNotificationsToExcel(GetAllNotificationsForExcelInput input);

    }
}