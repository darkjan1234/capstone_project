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
    [AbpAuthorize(AppPermissions.Pages_PttUsers)]
    public class PttUsersAppService : SolutionsAppServiceBase, IPttUsersAppService
    {
        private readonly IRepository<PttUser, Guid> _pttUserRepository;
        private readonly IPttUsersExcelExporter _pttUsersExcelExporter;

        public PttUsersAppService(IRepository<PttUser, Guid> pttUserRepository, IPttUsersExcelExporter pttUsersExcelExporter)
        {
            _pttUserRepository = pttUserRepository;
            _pttUsersExcelExporter = pttUsersExcelExporter;

        }

        public virtual async Task<PagedResultDto<GetPttUserForViewDto>> GetAll(GetAllPttUsersInput input)
        {

            var filteredPttUsers = _pttUserRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.FullName.Contains(input.Filter) || e.Email.Contains(input.Filter) || e.PasswordHash.Contains(input.Filter) || e.Role.Contains(input.Filter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.FullNameFilter), e => e.FullName.Contains(input.FullNameFilter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.EmailFilter), e => e.Email.Contains(input.EmailFilter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.PasswordHashFilter), e => e.PasswordHash.Contains(input.PasswordHashFilter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.RoleFilter), e => e.Role.Contains(input.RoleFilter))
                        .WhereIf(input.StatusFilter.HasValue && input.StatusFilter > -1, e => (input.StatusFilter == 1 && e.Status) || (input.StatusFilter == 0 && !e.Status));

            var pagedAndFilteredPttUsers = filteredPttUsers
                .OrderBy(input.Sorting ?? "id asc")
                .PageBy(input);

            var pttUsers = from o in pagedAndFilteredPttUsers
                           select new
                           {

                               o.FullName,
                               o.Email,
                               o.PasswordHash,
                               o.Role,
                               o.Status,
                               Id = o.Id
                           };

            var totalCount = await filteredPttUsers.CountAsync();

            var dbList = await pttUsers.ToListAsync();
            var results = new List<GetPttUserForViewDto>();

            foreach (var o in dbList)
            {
                var res = new GetPttUserForViewDto()
                {
                    PttUser = new PttUserDto
                    {

                        FullName = o.FullName,
                        Email = o.Email,
                        PasswordHash = o.PasswordHash,
                        Role = o.Role,
                        Status = o.Status,
                        Id = o.Id,
                    }
                };

                results.Add(res);
            }

            return new PagedResultDto<GetPttUserForViewDto>(
                totalCount,
                results
            );

        }

        public virtual async Task<GetPttUserForViewDto> GetPttUserForView(Guid id)
        {
            var pttUser = await _pttUserRepository.GetAsync(id);

            var output = new GetPttUserForViewDto { PttUser = ObjectMapper.Map<PttUserDto>(pttUser) };

            return output;
        }

        [AbpAuthorize(AppPermissions.Pages_PttUsers_Edit)]
        public virtual async Task<GetPttUserForEditOutput> GetPttUserForEdit(EntityDto<Guid> input)
        {
            var pttUser = await _pttUserRepository.FirstOrDefaultAsync(input.Id);

            var output = new GetPttUserForEditOutput { PttUser = ObjectMapper.Map<CreateOrEditPttUserDto>(pttUser) };

            return output;
        }

        public virtual async Task CreateOrEdit(CreateOrEditPttUserDto input)
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

        [AbpAuthorize(AppPermissions.Pages_PttUsers_Create)]
        protected virtual async Task Create(CreateOrEditPttUserDto input)
        {
            var pttUser = ObjectMapper.Map<PttUser>(input);

            if (AbpSession.TenantId != null)
            {
                pttUser.TenantId = (int?)AbpSession.TenantId;
            }

            await _pttUserRepository.InsertAsync(pttUser);

        }

        [AbpAuthorize(AppPermissions.Pages_PttUsers_Edit)]
        protected virtual async Task Update(CreateOrEditPttUserDto input)
        {
            var pttUser = await _pttUserRepository.FirstOrDefaultAsync((Guid)input.Id);
            ObjectMapper.Map(input, pttUser);

        }

        [AbpAuthorize(AppPermissions.Pages_PttUsers_Delete)]
        public virtual async Task Delete(EntityDto<Guid> input)
        {
            await _pttUserRepository.DeleteAsync(input.Id);
        }

        public virtual async Task<FileDto> GetPttUsersToExcel(GetAllPttUsersForExcelInput input)
        {

            var filteredPttUsers = _pttUserRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.FullName.Contains(input.Filter) || e.Email.Contains(input.Filter) || e.PasswordHash.Contains(input.Filter) || e.Role.Contains(input.Filter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.FullNameFilter), e => e.FullName.Contains(input.FullNameFilter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.EmailFilter), e => e.Email.Contains(input.EmailFilter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.PasswordHashFilter), e => e.PasswordHash.Contains(input.PasswordHashFilter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.RoleFilter), e => e.Role.Contains(input.RoleFilter))
                        .WhereIf(input.StatusFilter.HasValue && input.StatusFilter > -1, e => (input.StatusFilter == 1 && e.Status) || (input.StatusFilter == 0 && !e.Status));

            var query = (from o in filteredPttUsers
                         select new GetPttUserForViewDto()
                         {
                             PttUser = new PttUserDto
                             {
                                 FullName = o.FullName,
                                 Email = o.Email,
                                 PasswordHash = o.PasswordHash,
                                 Role = o.Role,
                                 Status = o.Status,
                                 Id = o.Id
                             }
                         });

            var pttUserListDtos = await query.ToListAsync();

            return _pttUsersExcelExporter.ExportToFile(pttUserListDtos);
        }

    }
}