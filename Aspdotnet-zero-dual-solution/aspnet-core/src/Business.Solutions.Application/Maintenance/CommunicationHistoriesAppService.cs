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
    [AbpAuthorize(AppPermissions.Pages_CommunicationHistories)]
    public class CommunicationHistoriesAppService : SolutionsAppServiceBase, ICommunicationHistoriesAppService
    {
        private readonly IRepository<CommunicationHistory, Guid> _communicationHistoryRepository;
        private readonly ICommunicationHistoriesExcelExporter _communicationHistoriesExcelExporter;

        public CommunicationHistoriesAppService(IRepository<CommunicationHistory, Guid> communicationHistoryRepository, ICommunicationHistoriesExcelExporter communicationHistoriesExcelExporter)
        {
            _communicationHistoryRepository = communicationHistoryRepository;
            _communicationHistoriesExcelExporter = communicationHistoriesExcelExporter;

        }

        public virtual async Task<PagedResultDto<GetCommunicationHistoryForViewDto>> GetAll(GetAllCommunicationHistoriesInput input)
        {

            var filteredCommunicationHistories = _communicationHistoryRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.Action.Contains(input.Filter))
                        .WhereIf(input.MinUserIdFilter != null, e => e.UserId >= input.MinUserIdFilter)
                        .WhereIf(input.MaxUserIdFilter != null, e => e.UserId <= input.MaxUserIdFilter)
                        .WhereIf(!string.IsNullOrWhiteSpace(input.ActionFilter), e => e.Action.Contains(input.ActionFilter))
                        .WhereIf(input.MinReferenceIdFilter != null, e => e.ReferenceId >= input.MinReferenceIdFilter)
                        .WhereIf(input.MaxReferenceIdFilter != null, e => e.ReferenceId <= input.MaxReferenceIdFilter);

            var pagedAndFilteredCommunicationHistories = filteredCommunicationHistories
                .OrderBy(input.Sorting ?? "id asc")
                .PageBy(input);

            var communicationHistories = from o in pagedAndFilteredCommunicationHistories
                                         select new
                                         {

                                             o.UserId,
                                             o.Action,
                                             o.ReferenceId,
                                             Id = o.Id
                                         };

            var totalCount = await filteredCommunicationHistories.CountAsync();

            var dbList = await communicationHistories.ToListAsync();
            var results = new List<GetCommunicationHistoryForViewDto>();

            foreach (var o in dbList)
            {
                var res = new GetCommunicationHistoryForViewDto()
                {
                    CommunicationHistory = new CommunicationHistoryDto
                    {

                        UserId = o.UserId,
                        Action = o.Action,
                        ReferenceId = o.ReferenceId,
                        Id = o.Id,
                    }
                };

                results.Add(res);
            }

            return new PagedResultDto<GetCommunicationHistoryForViewDto>(
                totalCount,
                results
            );

        }

        public virtual async Task<GetCommunicationHistoryForViewDto> GetCommunicationHistoryForView(Guid id)
        {
            var communicationHistory = await _communicationHistoryRepository.GetAsync(id);

            var output = new GetCommunicationHistoryForViewDto { CommunicationHistory = ObjectMapper.Map<CommunicationHistoryDto>(communicationHistory) };

            return output;
        }

        [AbpAuthorize(AppPermissions.Pages_CommunicationHistories_Edit)]
        public virtual async Task<GetCommunicationHistoryForEditOutput> GetCommunicationHistoryForEdit(EntityDto<Guid> input)
        {
            var communicationHistory = await _communicationHistoryRepository.FirstOrDefaultAsync(input.Id);

            var output = new GetCommunicationHistoryForEditOutput { CommunicationHistory = ObjectMapper.Map<CreateOrEditCommunicationHistoryDto>(communicationHistory) };

            return output;
        }

        public virtual async Task CreateOrEdit(CreateOrEditCommunicationHistoryDto input)
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

        [AbpAuthorize(AppPermissions.Pages_CommunicationHistories_Create)]
        protected virtual async Task Create(CreateOrEditCommunicationHistoryDto input)
        {
            var communicationHistory = ObjectMapper.Map<CommunicationHistory>(input);

            if (AbpSession.TenantId != null)
            {
                communicationHistory.TenantId = (int?)AbpSession.TenantId;
            }

            await _communicationHistoryRepository.InsertAsync(communicationHistory);

        }

        [AbpAuthorize(AppPermissions.Pages_CommunicationHistories_Edit)]
        protected virtual async Task Update(CreateOrEditCommunicationHistoryDto input)
        {
            var communicationHistory = await _communicationHistoryRepository.FirstOrDefaultAsync((Guid)input.Id);
            ObjectMapper.Map(input, communicationHistory);

        }

        [AbpAuthorize(AppPermissions.Pages_CommunicationHistories_Delete)]
        public virtual async Task Delete(EntityDto<Guid> input)
        {
            await _communicationHistoryRepository.DeleteAsync(input.Id);
        }

        public virtual async Task<FileDto> GetCommunicationHistoriesToExcel(GetAllCommunicationHistoriesForExcelInput input)
        {

            var filteredCommunicationHistories = _communicationHistoryRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.Action.Contains(input.Filter))
                        .WhereIf(input.MinUserIdFilter != null, e => e.UserId >= input.MinUserIdFilter)
                        .WhereIf(input.MaxUserIdFilter != null, e => e.UserId <= input.MaxUserIdFilter)
                        .WhereIf(!string.IsNullOrWhiteSpace(input.ActionFilter), e => e.Action.Contains(input.ActionFilter))
                        .WhereIf(input.MinReferenceIdFilter != null, e => e.ReferenceId >= input.MinReferenceIdFilter)
                        .WhereIf(input.MaxReferenceIdFilter != null, e => e.ReferenceId <= input.MaxReferenceIdFilter);

            var query = (from o in filteredCommunicationHistories
                         select new GetCommunicationHistoryForViewDto()
                         {
                             CommunicationHistory = new CommunicationHistoryDto
                             {
                                 UserId = o.UserId,
                                 Action = o.Action,
                                 ReferenceId = o.ReferenceId,
                                 Id = o.Id
                             }
                         });

            var communicationHistoryListDtos = await query.ToListAsync();

            return _communicationHistoriesExcelExporter.ExportToFile(communicationHistoryListDtos);
        }

    }
}