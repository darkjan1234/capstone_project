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
    [AbpAuthorize(AppPermissions.Pages_Logs)]
    public class LogsAppService : SolutionsAppServiceBase, ILogsAppService
    {
        private readonly IRepository<Log, Guid> _logRepository;
        private readonly ILogsExcelExporter _logsExcelExporter;

        public LogsAppService(IRepository<Log, Guid> logRepository, ILogsExcelExporter logsExcelExporter)
        {
            _logRepository = logRepository;
            _logsExcelExporter = logsExcelExporter;

        }

        public virtual async Task<PagedResultDto<GetLogForViewDto>> GetAll(GetAllLogsInput input)
        {

            var filteredLogs = _logRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.Activity.Contains(input.Filter) || e.LogLevel.Contains(input.Filter))
                        .WhereIf(input.MinUserIdFilter != null, e => e.UserId >= input.MinUserIdFilter)
                        .WhereIf(input.MaxUserIdFilter != null, e => e.UserId <= input.MaxUserIdFilter)
                        .WhereIf(!string.IsNullOrWhiteSpace(input.ActivityFilter), e => e.Activity.Contains(input.ActivityFilter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.LogLevelFilter), e => e.LogLevel.Contains(input.LogLevelFilter));

            var pagedAndFilteredLogs = filteredLogs
                .OrderBy(input.Sorting ?? "id asc")
                .PageBy(input);

            var logs = from o in pagedAndFilteredLogs
                       select new
                       {

                           o.UserId,
                           o.Activity,
                           o.LogLevel,
                           Id = o.Id
                       };

            var totalCount = await filteredLogs.CountAsync();

            var dbList = await logs.ToListAsync();
            var results = new List<GetLogForViewDto>();

            foreach (var o in dbList)
            {
                var res = new GetLogForViewDto()
                {
                    Log = new LogDto
                    {

                        UserId = o.UserId,
                        Activity = o.Activity,
                        LogLevel = o.LogLevel,
                        Id = o.Id,
                    }
                };

                results.Add(res);
            }

            return new PagedResultDto<GetLogForViewDto>(
                totalCount,
                results
            );

        }

        public virtual async Task<GetLogForViewDto> GetLogForView(Guid id)
        {
            var log = await _logRepository.GetAsync(id);

            var output = new GetLogForViewDto { Log = ObjectMapper.Map<LogDto>(log) };

            return output;
        }

        [AbpAuthorize(AppPermissions.Pages_Logs_Edit)]
        public virtual async Task<GetLogForEditOutput> GetLogForEdit(EntityDto<Guid> input)
        {
            var log = await _logRepository.FirstOrDefaultAsync(input.Id);

            var output = new GetLogForEditOutput { Log = ObjectMapper.Map<CreateOrEditLogDto>(log) };

            return output;
        }

        public virtual async Task CreateOrEdit(CreateOrEditLogDto input)
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

        [AbpAuthorize(AppPermissions.Pages_Logs_Create)]
        protected virtual async Task Create(CreateOrEditLogDto input)
        {
            var log = ObjectMapper.Map<Log>(input);

            if (AbpSession.TenantId != null)
            {
                log.TenantId = (int?)AbpSession.TenantId;
            }

            await _logRepository.InsertAsync(log);

        }

        [AbpAuthorize(AppPermissions.Pages_Logs_Edit)]
        protected virtual async Task Update(CreateOrEditLogDto input)
        {
            var log = await _logRepository.FirstOrDefaultAsync((Guid)input.Id);
            ObjectMapper.Map(input, log);

        }

        [AbpAuthorize(AppPermissions.Pages_Logs_Delete)]
        public virtual async Task Delete(EntityDto<Guid> input)
        {
            await _logRepository.DeleteAsync(input.Id);
        }

        public virtual async Task<FileDto> GetLogsToExcel(GetAllLogsForExcelInput input)
        {

            var filteredLogs = _logRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.Activity.Contains(input.Filter) || e.LogLevel.Contains(input.Filter))
                        .WhereIf(input.MinUserIdFilter != null, e => e.UserId >= input.MinUserIdFilter)
                        .WhereIf(input.MaxUserIdFilter != null, e => e.UserId <= input.MaxUserIdFilter)
                        .WhereIf(!string.IsNullOrWhiteSpace(input.ActivityFilter), e => e.Activity.Contains(input.ActivityFilter))
                        .WhereIf(!string.IsNullOrWhiteSpace(input.LogLevelFilter), e => e.LogLevel.Contains(input.LogLevelFilter));

            var query = (from o in filteredLogs
                         select new GetLogForViewDto()
                         {
                             Log = new LogDto
                             {
                                 UserId = o.UserId,
                                 Activity = o.Activity,
                                 LogLevel = o.LogLevel,
                                 Id = o.Id
                             }
                         });

            var logListDtos = await query.ToListAsync();

            return _logsExcelExporter.ExportToFile(logListDtos);
        }

    }
}