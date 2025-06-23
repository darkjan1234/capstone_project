using System;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;

namespace Business.Solutions.Maintenance
{
    public interface IGroupsAppService : IApplicationService
    {
        Task<PagedResultDto<GetGroupForViewDto>> GetAll(GetAllGroupsInput input);

        Task<GetGroupForViewDto> GetGroupForView(Guid id);

        Task<GetGroupForEditOutput> GetGroupForEdit(EntityDto<Guid> input);

        Task CreateOrEdit(CreateOrEditGroupDto input);

        Task Delete(EntityDto<Guid> input);

        Task<FileDto> GetGroupsToExcel(GetAllGroupsForExcelInput input);

    }
}