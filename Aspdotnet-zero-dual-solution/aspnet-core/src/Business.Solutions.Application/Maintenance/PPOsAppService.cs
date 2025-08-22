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
    [AbpAuthorize(AppPermissions.Pages_PPOs)]
    public class PPOsAppService : SolutionsAppServiceBase, IPPOsAppService
    {
        private readonly IRepository<PPO, Guid> _ppoRepository;
        private readonly IPPOsExcelExporter _ppOsExcelExporter;

        public PPOsAppService(IRepository<PPO, Guid> ppoRepository, IPPOsExcelExporter ppOsExcelExporter)
        {
            _ppoRepository = ppoRepository;
            _ppOsExcelExporter = ppOsExcelExporter;

        }

        public virtual async Task<PagedResultDto<GetPPOForViewDto>> GetAll(GetAllPPOsInput input)
        {

            var filteredPPOs = _ppoRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.ProvincialName.Contains(input.Filter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.ProvincialNameFilter), e => e.ProvincialName.Contains(input.ProvincialNameFilter))
                        .WhereIf(input.isActiveFilter.HasValue && input.isActiveFilter > -1, e => (input.isActiveFilter == 1 && e.isActive) || (input.isActiveFilter == 0 && !e.isActive));

            var pagedAndFilteredPPOs = filteredPPOs
                .OrderBy(input.Sorting ?? "id asc")
                .PageBy(input);

            var ppOs = from o in pagedAndFilteredPPOs
                       select new
                       {

                           o.ProvincialName,
                           o.isActive,
                           Id = o.Id
                       };

            var totalCount = await filteredPPOs.CountAsync();

            var dbList = await ppOs.ToListAsync();
            var results = new List<GetPPOForViewDto>();

            foreach (var o in dbList)
            {
                var res = new GetPPOForViewDto()
                {
                    PPO = new PPODto
                    {

                        ProvincialName = o.ProvincialName,
                        isActive = o.isActive,
                        Id = o.Id,
                    }
                };

                results.Add(res);
            }

            return new PagedResultDto<GetPPOForViewDto>(
                totalCount,
                results
            );

        }

        public virtual async Task<GetPPOForViewDto> GetPPOForView(Guid id)
        {
            var ppo = await _ppoRepository.GetAsync(id);

            var output = new GetPPOForViewDto { PPO = ObjectMapper.Map<PPODto>(ppo) };

            return output;
        }

        [AbpAuthorize(AppPermissions.Pages_PPOs_Edit)]
        public virtual async Task<GetPPOForEditOutput> GetPPOForEdit(EntityDto<Guid> input)
        {
            var ppo = await _ppoRepository.FirstOrDefaultAsync(input.Id);

            var output = new GetPPOForEditOutput { PPO = ObjectMapper.Map<CreateOrEditPPODto>(ppo) };

            return output;
        }

        public virtual async Task CreateOrEdit(CreateOrEditPPODto input)
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

        [AbpAuthorize(AppPermissions.Pages_PPOs_Create)]
        protected virtual async Task Create(CreateOrEditPPODto input)
        {
            var ppo = ObjectMapper.Map<PPO>(input);

            if (AbpSession.TenantId != null)
            {
                ppo.TenantId = (int?)AbpSession.TenantId;
            }

            await _ppoRepository.InsertAsync(ppo);

        }

        [AbpAuthorize(AppPermissions.Pages_PPOs_Edit)]
        protected virtual async Task Update(CreateOrEditPPODto input)
        {
            var ppo = await _ppoRepository.FirstOrDefaultAsync((Guid)input.Id);
            ObjectMapper.Map(input, ppo);

        }

        [AbpAuthorize(AppPermissions.Pages_PPOs_Delete)]
        public virtual async Task Delete(EntityDto<Guid> input)
        {
            await _ppoRepository.DeleteAsync(input.Id);
        }

        public virtual async Task<FileDto> GetPPOsToExcel(GetAllPPOsForExcelInput input)
        {

            var filteredPPOs = _ppoRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.ProvincialName.Contains(input.Filter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.ProvincialNameFilter), e => e.ProvincialName.Contains(input.ProvincialNameFilter))
                        .WhereIf(input.isActiveFilter.HasValue && input.isActiveFilter > -1, e => (input.isActiveFilter == 1 && e.isActive) || (input.isActiveFilter == 0 && !e.isActive));

            var query = (from o in filteredPPOs
                         select new GetPPOForViewDto()
                         {
                             PPO = new PPODto
                             {
                                 ProvincialName = o.ProvincialName,
                                 isActive = o.isActive,
                                 Id = o.Id
                             }
                         });

            var ppoListDtos = await query.ToListAsync();

            return _ppOsExcelExporter.ExportToFile(ppoListDtos);
        }

    }
}