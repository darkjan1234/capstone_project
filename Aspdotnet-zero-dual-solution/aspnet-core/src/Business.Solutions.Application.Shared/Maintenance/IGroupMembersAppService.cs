using System;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;

namespace Business.Solutions.Maintenance
{
    public interface IGroupMembersAppService : IApplicationService
    {
        Task<PagedResultDto<GetGroupMemberForViewDto>> GetAll(GetAllGroupMembersInput input);

        Task<GetGroupMemberForViewDto> GetGroupMemberForView(Guid id);

        Task<GetGroupMemberForEditOutput> GetGroupMemberForEdit(EntityDto<Guid> input);

        Task CreateOrEdit(CreateOrEditGroupMemberDto input);

        Task Delete(EntityDto<Guid> input);

        Task<FileDto> GetGroupMembersToExcel(GetAllGroupMembersForExcelInput input);

    }
}