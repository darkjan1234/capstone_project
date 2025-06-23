using System;
using System.Linq;
using System.Linq.Dynamic.Core;
using Abp.Linq.Extensions;
using System.Collections.Generic;
using System.Threading.Tasks;
using Abp.Domain.Repositories;
using Business.Solutions.Maintenance.Exporting;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;
using Abp.Application.Services.Dto;
using Business.Solutions.Authorization;
using Abp.Extensions;
using Abp.Authorization;
using Microsoft.EntityFrameworkCore;
using Abp.UI;
using Business.Solutions.Storage;

namespace Business.Solutions.Maintenance
{
    [AbpAuthorize(AppPermissions.Pages_GroupMembers)]
    public class GroupMembersAppService : SolutionsAppServiceBase, IGroupMembersAppService
    {
        private readonly IRepository<GroupMember, Guid> _groupMemberRepository;
        private readonly IGroupMembersExcelExporter _groupMembersExcelExporter;

        public GroupMembersAppService(IRepository<GroupMember, Guid> groupMemberRepository, IGroupMembersExcelExporter groupMembersExcelExporter)
        {
            _groupMemberRepository = groupMemberRepository;
            _groupMembersExcelExporter = groupMembersExcelExporter;

        }

        public virtual async Task<PagedResultDto<GetGroupMemberForViewDto>> GetAll(GetAllGroupMembersInput input)
        {

            var filteredGroupMembers = _groupMemberRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.PttUserId.Contains(input.Filter) || e.RoleInGroup.Contains(input.Filter))
                        .WhereIf(input.MinGroupIdFilter != null, e => e.GroupId >= input.MinGroupIdFilter)
                        .WhereIf(input.MaxGroupIdFilter != null, e => e.GroupId <= input.MaxGroupIdFilter)
                        .WhereIf(!string.IsNullOrWhiteSpace(input.PttUserIdFilter), e => e.PttUserId.Contains(input.PttUserIdFilter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.RoleInGroupFilter), e => e.RoleInGroup.Contains(input.RoleInGroupFilter));

            var pagedAndFilteredGroupMembers = filteredGroupMembers
                .OrderBy(input.Sorting ?? "id asc")
                .PageBy(input);

            var groupMembers = from o in pagedAndFilteredGroupMembers
                               select new
                               {

                                   o.GroupId,
                                   o.PttUserId,
                                   o.RoleInGroup,
                                   Id = o.Id
                               };

            var totalCount = await filteredGroupMembers.CountAsync();

            var dbList = await groupMembers.ToListAsync();
            var results = new List<GetGroupMemberForViewDto>();

            foreach (var o in dbList)
            {
                var res = new GetGroupMemberForViewDto()
                {
                    GroupMember = new GroupMemberDto
                    {

                        GroupId = o.GroupId,
                        PttUserId = o.PttUserId,
                        RoleInGroup = o.RoleInGroup,
                        Id = o.Id,
                    }
                };

                results.Add(res);
            }

            return new PagedResultDto<GetGroupMemberForViewDto>(
                totalCount,
                results
            );

        }

        public virtual async Task<GetGroupMemberForViewDto> GetGroupMemberForView(Guid id)
        {
            var groupMember = await _groupMemberRepository.GetAsync(id);

            var output = new GetGroupMemberForViewDto { GroupMember = ObjectMapper.Map<GroupMemberDto>(groupMember) };

            return output;
        }

        [AbpAuthorize(AppPermissions.Pages_GroupMembers_Edit)]
        public virtual async Task<GetGroupMemberForEditOutput> GetGroupMemberForEdit(EntityDto<Guid> input)
        {
            var groupMember = await _groupMemberRepository.FirstOrDefaultAsync(input.Id);

            var output = new GetGroupMemberForEditOutput { GroupMember = ObjectMapper.Map<CreateOrEditGroupMemberDto>(groupMember) };

            return output;
        }

        public virtual async Task CreateOrEdit(CreateOrEditGroupMemberDto input)
        {
            if (input.Id == null)
            {
                await Create(input);
            }
            else
            {
                await Update(input);
            }
        }

        [AbpAuthorize(AppPermissions.Pages_GroupMembers_Create)]
        protected virtual async Task Create(CreateOrEditGroupMemberDto input)
        {
            var groupMember = ObjectMapper.Map<GroupMember>(input);

            if (AbpSession.TenantId != null)
            {
                groupMember.TenantId = (int?)AbpSession.TenantId;
            }

            await _groupMemberRepository.InsertAsync(groupMember);

        }

        [AbpAuthorize(AppPermissions.Pages_GroupMembers_Edit)]
        protected virtual async Task Update(CreateOrEditGroupMemberDto input)
        {
            var groupMember = await _groupMemberRepository.FirstOrDefaultAsync((Guid)input.Id);
            ObjectMapper.Map(input, groupMember);

        }

        [AbpAuthorize(AppPermissions.Pages_GroupMembers_Delete)]
        public virtual async Task Delete(EntityDto<Guid> input)
        {
            await _groupMemberRepository.DeleteAsync(input.Id);
        }

        public virtual async Task<FileDto> GetGroupMembersToExcel(GetAllGroupMembersForExcelInput input)
        {

            var filteredGroupMembers = _groupMemberRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.PttUserId.Contains(input.Filter) || e.RoleInGroup.Contains(input.Filter))
                        .WhereIf(input.MinGroupIdFilter != null, e => e.GroupId >= input.MinGroupIdFilter)
                        .WhereIf(input.MaxGroupIdFilter != null, e => e.GroupId <= input.MaxGroupIdFilter)
                        .WhereIf(!string.IsNullOrWhiteSpace(input.PttUserIdFilter), e => e.PttUserId.Contains(input.PttUserIdFilter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.RoleInGroupFilter), e => e.RoleInGroup.Contains(input.RoleInGroupFilter));

            var query = (from o in filteredGroupMembers
                         select new GetGroupMemberForViewDto()
                         {
                             GroupMember = new GroupMemberDto
                             {
                                 GroupId = o.GroupId,
                                 PttUserId = o.PttUserId,
                                 RoleInGroup = o.RoleInGroup,
                                 Id = o.Id
                             }
                         });

            var groupMemberListDtos = await query.ToListAsync();

            return _groupMembersExcelExporter.ExportToFile(groupMemberListDtos);
        }

    }
}