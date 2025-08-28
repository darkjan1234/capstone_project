using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Abp.Application.Services.Dto;
using Abp.Authorization;
using Abp.Domain.Repositories;
using Abp.Linq.Extensions;
using Abp.Runtime.Session;
using Abp;
using Business.Solutions.Authorization;
using Business.Solutions.Authorization.Users;
using Business.Solutions.PTT.Dto;
using Microsoft.EntityFrameworkCore;
using System.Linq.Dynamic.Core;
using Abp.Extensions;
using Abp.UI;

namespace Business.Solutions.PTT
{
    [AbpAuthorize(AppPermissions.Pages_Administration_Users)]
    public class PttGroupAppService : SolutionsAppServiceBase, IPttGroupAppService
    {
        private readonly IRepository<PttGroup, long> _pttGroupRepository;
        private readonly IRepository<PttGroupMember, long> _pttGroupMemberRepository;
        private readonly IRepository<User, long> _userRepository;

        public PttGroupAppService(
            IRepository<PttGroup, long> pttGroupRepository,
            IRepository<PttGroupMember, long> pttGroupMemberRepository,
            IRepository<User, long> userRepository)
        {
            _pttGroupRepository = pttGroupRepository;
            _pttGroupMemberRepository = pttGroupMemberRepository;
            _userRepository = userRepository;
        }

        public async Task<PagedResultDto<PttGroupListDto>> GetPttGroups(GetPttGroupsInput input)
        {
            var currentUserId = AbpSession.UserId ?? 0;
            
            var query = _pttGroupRepository.GetAll()
                .Include(g => g.CreatedByAdmin)
                .Include(g => g.ParentGroup)
                .Include(g => g.Members)
                .Where(g => g.CreatedByAdminId == currentUserId || IsUserSuperAdmin()) // Only show groups created by current admin
                .WhereIf(!input.Filter.IsNullOrWhiteSpace(), 
                    g => g.Name.Contains(input.Filter) || g.Description.Contains(input.Filter))
                .WhereIf(input.GroupType.HasValue, g => g.GroupType == input.GroupType)
                .WhereIf(input.IsActive.HasValue, g => g.IsActive == input.IsActive)
                .WhereIf(input.CreatedByAdminId.HasValue, g => g.CreatedByAdminId == input.CreatedByAdminId);

            var totalCount = await query.CountAsync();

            var groups = await query
                .OrderBy(input.Sorting ?? "name asc")
                .PageBy(input)
                .ToListAsync();

            var groupListDtos = groups.Select(g => new PttGroupListDto
            {
                Id = g.Id,
                Name = g.Name,
                Description = g.Description,
                CreatedByAdminId = g.CreatedByAdminId,
                CreatedByAdminName = g.CreatedByAdmin?.FullName,
                ParentGroupId = g.ParentGroupId,
                ParentGroupName = g.ParentGroup?.Name,
                HierarchyLevel = g.HierarchyLevel,
                IsActive = g.IsActive,
                GroupType = g.GroupType,
                MemberCount = g.Members.Count(m => m.IsActive),
                CreationTime = g.CreationTime
            }).ToList();

            return new PagedResultDto<PttGroupListDto>(totalCount, groupListDtos);
        }

        public async Task<GetPttGroupForEditOutput> GetPttGroupForEdit(EntityDto<long> input)
        {
            var group = await _pttGroupRepository.GetAsync(input.Id);
            
            // Check if current user can edit this group
            if (group.CreatedByAdminId != (AbpSession.UserId ?? 0) && !IsUserSuperAdmin())
            {
                throw new UserFriendlyException("You can only edit groups you created.");
            }

            var editDto = ObjectMapper.Map<CreateOrEditPttGroupDto>(group);
            
            return new GetPttGroupForEditOutput
            {
                PttGroup = editDto
            };
        }

        public async Task CreateOrEdit(CreateOrEditPttGroupDto input)
        {
            if (input.Id.HasValue)
            {
                await UpdatePttGroup(input);
            }
            else
            {
                await CreatePttGroup(input);
            }
        }

        private async Task CreatePttGroup(CreateOrEditPttGroupDto input)
        {
            var currentUserId = AbpSession.UserId ?? 0;
            
            // Validate parent group if specified
            if (input.ParentGroupId.HasValue)
            {
                var parentGroup = await _pttGroupRepository.GetAsync(input.ParentGroupId.Value);
                if (parentGroup.CreatedByAdminId != currentUserId && !IsUserSuperAdmin())
                {
                    throw new UserFriendlyException("You can only create subgroups under your own groups.");
                }
            }

            var group = ObjectMapper.Map<PttGroup>(input);
            group.CreatedByAdminId = currentUserId;
            group.HierarchyLevel = await CalculateHierarchyLevel(input.ParentGroupId);

            await _pttGroupRepository.InsertAsync(group);
        }

        private async Task UpdatePttGroup(CreateOrEditPttGroupDto input)
        {
            var group = await _pttGroupRepository.GetAsync(input.Id.Value);
            
            // Check permissions
            if (group.CreatedByAdminId != (AbpSession.UserId ?? 0) && !IsUserSuperAdmin())
            {
                throw new UserFriendlyException("You can only edit groups you created.");
            }

            ObjectMapper.Map(input, group);
            group.HierarchyLevel = await CalculateHierarchyLevel(input.ParentGroupId);
            
            await _pttGroupRepository.UpdateAsync(group);
        }

        public async Task Delete(EntityDto<long> input)
        {
            var group = await _pttGroupRepository.GetAsync(input.Id);
            
            // Check permissions
            if (group.CreatedByAdminId != (AbpSession.UserId ?? 0) && !IsUserSuperAdmin())
            {
                throw new UserFriendlyException("You can only delete groups you created.");
            }

            // Check if group has children
            var hasChildren = await _pttGroupRepository.CountAsync(g => g.ParentGroupId == input.Id) > 0;
            if (hasChildren)
            {
                throw new UserFriendlyException("Cannot delete group that has child groups. Delete child groups first.");
            }

            // Remove all members first
            var members = await _pttGroupMemberRepository.GetAllListAsync(m => m.PttGroupId == input.Id);
            foreach (var member in members)
            {
                await _pttGroupMemberRepository.DeleteAsync(member);
            }

            await _pttGroupRepository.DeleteAsync(input.Id);
        }

        public async Task<PagedResultDto<PttGroupMemberListDto>> GetGroupMembers(GetGroupMembersInput input)
        {
            var group = await _pttGroupRepository.GetAsync(input.GroupId);
            
            // Check permissions
            if (group.CreatedByAdminId != (AbpSession.UserId ?? 0) && !IsUserSuperAdmin())
            {
                throw new UserFriendlyException("You can only view members of groups you created.");
            }

            var query = _pttGroupMemberRepository.GetAll()
                .Include(m => m.User)
                .Include(m => m.PttGroup)
                .Include(m => m.AddedByAdmin)
                .Where(m => m.PttGroupId == input.GroupId)
                .WhereIf(!input.Filter.IsNullOrWhiteSpace(), 
                    m => m.User.UserName.Contains(input.Filter) || 
                         m.User.Name.Contains(input.Filter) || 
                         m.User.Surname.Contains(input.Filter))
                .WhereIf(input.Role.HasValue, m => m.Role == input.Role)
                .WhereIf(input.IsActive.HasValue, m => m.IsActive == input.IsActive);

            var totalCount = await query.CountAsync();

            var members = await query
                .OrderBy(input.Sorting ?? "user.name asc")
                .PageBy(input)
                .ToListAsync();

            var memberListDtos = members.Select(m => new PttGroupMemberListDto
            {
                Id = m.Id,
                PttGroupId = m.PttGroupId,
                PttGroupName = m.PttGroup.Name,
                UserId = m.UserId,
                UserName = m.User.UserName,
                UserFullName = m.User.FullName,
                UserEmailAddress = m.User.EmailAddress,
                Role = m.Role,
                IsActive = m.IsActive,
                JoinedDate = m.JoinedDate,
                AddedByAdminId = m.AddedByAdminId,
                AddedByAdminName = m.AddedByAdmin?.FullName
            }).ToList();

            return new PagedResultDto<PttGroupMemberListDto>(totalCount, memberListDtos);
        }

        public async Task AddUserToGroup(AddUserToGroupInput input)
        {
            var group = await _pttGroupRepository.GetAsync(input.GroupId);
            
            // Check permissions
            if (group.CreatedByAdminId != (AbpSession.UserId ?? 0) && !IsUserSuperAdmin())
            {
                throw new UserFriendlyException("You can only add users to groups you created.");
            }

            // Check if user is already in the group
            var existingMember = await _pttGroupMemberRepository.FirstOrDefaultAsync(
                m => m.PttGroupId == input.GroupId && m.UserId == input.UserId);
            
            if (existingMember != null)
            {
                if (existingMember.IsActive)
                {
                    throw new UserFriendlyException("User is already a member of this group.");
                }
                else
                {
                    // Reactivate the member
                    existingMember.IsActive = true;
                    existingMember.Role = input.Role;
                    existingMember.JoinedDate = DateTime.UtcNow;
                    existingMember.AddedByAdminId = AbpSession.UserId ?? 0;
                    await _pttGroupMemberRepository.UpdateAsync(existingMember);
                }
            }
            else
            {
                var member = new PttGroupMember(input.GroupId, input.UserId, input.Role, AbpSession.UserId ?? 0);
                await _pttGroupMemberRepository.InsertAsync(member);
            }
        }

        public async Task RemoveUserFromGroup(RemoveUserFromGroupInput input)
        {
            var group = await _pttGroupRepository.GetAsync(input.GroupId);
            
            // Check permissions
            if (group.CreatedByAdminId != (AbpSession.UserId ?? 0) && !IsUserSuperAdmin())
            {
                throw new UserFriendlyException("You can only remove users from groups you created.");
            }

            var member = await _pttGroupMemberRepository.FirstOrDefaultAsync(
                m => m.PttGroupId == input.GroupId && m.UserId == input.UserId);
            
            if (member != null)
            {
                await _pttGroupMemberRepository.DeleteAsync(member);
            }
        }

        public async Task<ListResultDto<PttGroupHierarchyDto>> GetGroupHierarchy()
        {
            var currentUserId = AbpSession.UserId ?? 0;
            
            var groups = await _pttGroupRepository.GetAll()
                .Include(g => g.CreatedByAdmin)
                .Include(g => g.Members)
                .Where(g => g.CreatedByAdminId == currentUserId || IsUserSuperAdmin())
                .Where(g => g.IsActive)
                .ToListAsync();

            var hierarchyDtos = BuildHierarchy(groups, null);
            
            return new ListResultDto<PttGroupHierarchyDto>(hierarchyDtos);
        }

        public async Task<ListResultDto<PttGroupListDto>> GetMyGroups()
        {
            var currentUserId = AbpSession.UserId ?? 0;
            
            var groups = await _pttGroupRepository.GetAll()
                .Include(g => g.CreatedByAdmin)
                .Include(g => g.Members)
                .Where(g => g.CreatedByAdminId == currentUserId)
                .Where(g => g.IsActive)
                .ToListAsync();

            var groupDtos = groups.Select(g => new PttGroupListDto
            {
                Id = g.Id,
                Name = g.Name,
                Description = g.Description,
                GroupType = g.GroupType,
                MemberCount = g.Members.Count(m => m.IsActive),
                IsActive = g.IsActive,
                CreationTime = g.CreationTime
            }).ToList();

            return new ListResultDto<PttGroupListDto>(groupDtos);
        }

        public async Task<ListResultDto<UserListDto>> GetAvailableUsers()
        {
            var users = await _userRepository.GetAll()
                .Where(u => u.IsActive)
                .ToListAsync();

            var userDtos = users.Select(u => new UserListDto
            {
                Id = u.Id,
                UserName = u.UserName,
                Name = u.Name,
                Surname = u.Surname,
                EmailAddress = u.EmailAddress,
                IsActive = u.IsActive
            }).ToList();

            return new ListResultDto<UserListDto>(userDtos);
        }

        private List<PttGroupHierarchyDto> BuildHierarchy(List<PttGroup> groups, long? parentId)
        {
            return groups
                .Where(g => g.ParentGroupId == parentId)
                .Select(g => new PttGroupHierarchyDto
                {
                    Id = g.Id,
                    Name = g.Name,
                    Description = g.Description,
                    CreatedByAdminId = g.CreatedByAdminId,
                    CreatedByAdminName = g.CreatedByAdmin?.FullName,
                    ParentGroupId = g.ParentGroupId,
                    HierarchyLevel = g.HierarchyLevel,
                    GroupType = g.GroupType,
                    IsActive = g.IsActive,
                    MemberCount = g.Members.Count(m => m.IsActive),
                    Children = BuildHierarchy(groups, g.Id)
                })
                .ToList();
        }

        private async Task<int> CalculateHierarchyLevel(long? parentGroupId)
        {
            if (!parentGroupId.HasValue)
                return 0;

            var parentGroup = await _pttGroupRepository.GetAsync(parentGroupId.Value);
            return parentGroup.HierarchyLevel + 1;
        }

        private bool IsUserSuperAdmin()
        {
            // Check if current user is super admin or has special permissions
            return AbpSession.UserId == 1; // Assuming user ID 1 is super admin
        }
    }
}
