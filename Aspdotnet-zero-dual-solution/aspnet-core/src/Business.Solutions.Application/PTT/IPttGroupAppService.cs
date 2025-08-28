using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.PTT.Dto;

namespace Business.Solutions.PTT
{
    public interface IPttGroupAppService : IApplicationService
    {
        Task<PagedResultDto<PttGroupListDto>> GetPttGroups(GetPttGroupsInput input);
        
        Task<GetPttGroupForEditOutput> GetPttGroupForEdit(EntityDto<long> input);
        
        Task CreateOrEdit(CreateOrEditPttGroupDto input);
        
        Task Delete(EntityDto<long> input);
        
        Task<PagedResultDto<PttGroupMemberListDto>> GetGroupMembers(GetGroupMembersInput input);
        
        Task AddUserToGroup(AddUserToGroupInput input);
        
        Task RemoveUserFromGroup(RemoveUserFromGroupInput input);
        
        Task<ListResultDto<PttGroupHierarchyDto>> GetGroupHierarchy();
        
        Task<ListResultDto<PttGroupListDto>> GetMyGroups();
        
        Task<ListResultDto<UserListDto>> GetAvailableUsers();
    }
}
