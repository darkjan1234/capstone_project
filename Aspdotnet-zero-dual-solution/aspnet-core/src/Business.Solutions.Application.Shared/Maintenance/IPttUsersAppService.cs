using System;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;

namespace Business.Solutions.Maintenance
{
    public interface IPttUsersAppService : IApplicationService
    {
        Task<PagedResultDto<GetPttUserForViewDto>> GetAll(GetAllPttUsersInput input);

        Task<GetPttUserForViewDto> GetPttUserForView(Guid id);

        Task<GetPttUserForEditOutput> GetPttUserForEdit(EntityDto<Guid> input);

        Task CreateOrEdit(CreateOrEditPttUserDto input);

        Task Delete(EntityDto<Guid> input);

        Task<FileDto> GetPttUsersToExcel(GetAllPttUsersForExcelInput input);

    }
}