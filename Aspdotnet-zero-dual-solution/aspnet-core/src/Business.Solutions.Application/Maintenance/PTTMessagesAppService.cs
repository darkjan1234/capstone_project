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
    [AbpAuthorize(AppPermissions.Pages_PTTMessages)]
    public class PTTMessagesAppService : SolutionsAppServiceBase, IPTTMessagesAppService
    {
        private readonly IRepository<PTTMessage, Guid> _pttMessageRepository;
        private readonly IPTTMessagesExcelExporter _pttMessagesExcelExporter;

        public PTTMessagesAppService(IRepository<PTTMessage, Guid> pttMessageRepository, IPTTMessagesExcelExporter pttMessagesExcelExporter)
        {
            _pttMessageRepository = pttMessageRepository;
            _pttMessagesExcelExporter = pttMessagesExcelExporter;

        }

        public virtual async Task<PagedResultDto<GetPTTMessageForViewDto>> GetAll(GetAllPTTMessagesInput input)
        {

            var filteredPTTMessages = _pttMessageRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.AudioPath.Contains(input.Filter))
                        .WhereIf(input.MinSenderIdFilter != null, e => e.SenderId >= input.MinSenderIdFilter)
                        .WhereIf(input.MaxSenderIdFilter != null, e => e.SenderId <= input.MaxSenderIdFilter)
                        .WhereIf(input.MinReceiverIdFilter != null, e => e.ReceiverId >= input.MinReceiverIdFilter)
                        .WhereIf(input.MaxReceiverIdFilter != null, e => e.ReceiverId <= input.MaxReceiverIdFilter)
                        .WhereIf(input.MinGroupIdFilter != null, e => e.GroupId >= input.MinGroupIdFilter)
                        .WhereIf(input.MaxGroupIdFilter != null, e => e.GroupId <= input.MaxGroupIdFilter)
                        .WhereIf(!string.IsNullOrWhiteSpace(input.AudioPathFilter), e => e.AudioPath.Contains(input.AudioPathFilter))
                        .WhereIf(input.MinDurationSecondsFilter != null, e => e.DurationSeconds >= input.MinDurationSecondsFilter)
                        .WhereIf(input.MaxDurationSecondsFilter != null, e => e.DurationSeconds <= input.MaxDurationSecondsFilter);

            var pagedAndFilteredPTTMessages = filteredPTTMessages
                .OrderBy(input.Sorting ?? "id asc")
                .PageBy(input);

            var pttMessages = from o in pagedAndFilteredPTTMessages
                              select new
                              {

                                  o.SenderId,
                                  o.ReceiverId,
                                  o.GroupId,
                                  o.AudioPath,
                                  o.DurationSeconds,
                                  Id = o.Id
                              };

            var totalCount = await filteredPTTMessages.CountAsync();

            var dbList = await pttMessages.ToListAsync();
            var results = new List<GetPTTMessageForViewDto>();

            foreach (var o in dbList)
            {
                var res = new GetPTTMessageForViewDto()
                {
                    PTTMessage = new PTTMessageDto
                    {

                        SenderId = o.SenderId,
                        ReceiverId = o.ReceiverId,
                        GroupId = o.GroupId,
                        AudioPath = o.AudioPath,
                        DurationSeconds = o.DurationSeconds,
                        Id = o.Id,
                    }
                };

                results.Add(res);
            }

            return new PagedResultDto<GetPTTMessageForViewDto>(
                totalCount,
                results
            );

        }

        public virtual async Task<GetPTTMessageForViewDto> GetPTTMessageForView(Guid id)
        {
            var pttMessage = await _pttMessageRepository.GetAsync(id);

            var output = new GetPTTMessageForViewDto { PTTMessage = ObjectMapper.Map<PTTMessageDto>(pttMessage) };

            return output;
        }

        [AbpAuthorize(AppPermissions.Pages_PTTMessages_Edit)]
        public virtual async Task<GetPTTMessageForEditOutput> GetPTTMessageForEdit(EntityDto<Guid> input)
        {
            var pttMessage = await _pttMessageRepository.FirstOrDefaultAsync(input.Id);

            var output = new GetPTTMessageForEditOutput { PTTMessage = ObjectMapper.Map<CreateOrEditPTTMessageDto>(pttMessage) };

            return output;
        }

        public virtual async Task CreateOrEdit(CreateOrEditPTTMessageDto input)
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

        [AbpAuthorize(AppPermissions.Pages_PTTMessages_Create)]
        protected virtual async Task Create(CreateOrEditPTTMessageDto input)
        {
            var pttMessage = ObjectMapper.Map<PTTMessage>(input);

            if (AbpSession.TenantId != null)
            {
                pttMessage.TenantId = (int?)AbpSession.TenantId;
            }

            await _pttMessageRepository.InsertAsync(pttMessage);

        }

        [AbpAuthorize(AppPermissions.Pages_PTTMessages_Edit)]
        protected virtual async Task Update(CreateOrEditPTTMessageDto input)
        {
            var pttMessage = await _pttMessageRepository.FirstOrDefaultAsync((Guid)input.Id);
            ObjectMapper.Map(input, pttMessage);

        }

        [AbpAuthorize(AppPermissions.Pages_PTTMessages_Delete)]
        public virtual async Task Delete(EntityDto<Guid> input)
        {
            await _pttMessageRepository.DeleteAsync(input.Id);
        }

        public virtual async Task<FileDto> GetPTTMessagesToExcel(GetAllPTTMessagesForExcelInput input)
        {

            var filteredPTTMessages = _pttMessageRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.AudioPath.Contains(input.Filter))
                        .WhereIf(input.MinSenderIdFilter != null, e => e.SenderId >= input.MinSenderIdFilter)
                        .WhereIf(input.MaxSenderIdFilter != null, e => e.SenderId <= input.MaxSenderIdFilter)
                        .WhereIf(input.MinReceiverIdFilter != null, e => e.ReceiverId >= input.MinReceiverIdFilter)
                        .WhereIf(input.MaxReceiverIdFilter != null, e => e.ReceiverId <= input.MaxReceiverIdFilter)
                        .WhereIf(input.MinGroupIdFilter != null, e => e.GroupId >= input.MinGroupIdFilter)
                        .WhereIf(input.MaxGroupIdFilter != null, e => e.GroupId <= input.MaxGroupIdFilter)
                        .WhereIf(!string.IsNullOrWhiteSpace(input.AudioPathFilter), e => e.AudioPath.Contains(input.AudioPathFilter))
                        .WhereIf(input.MinDurationSecondsFilter != null, e => e.DurationSeconds >= input.MinDurationSecondsFilter)
                        .WhereIf(input.MaxDurationSecondsFilter != null, e => e.DurationSeconds <= input.MaxDurationSecondsFilter);

            var query = (from o in filteredPTTMessages
                         select new GetPTTMessageForViewDto()
                         {
                             PTTMessage = new PTTMessageDto
                             {
                                 SenderId = o.SenderId,
                                 ReceiverId = o.ReceiverId,
                                 GroupId = o.GroupId,
                                 AudioPath = o.AudioPath,
                                 DurationSeconds = o.DurationSeconds,
                                 Id = o.Id
                             }
                         });

            var pttMessageListDtos = await query.ToListAsync();

            return _pttMessagesExcelExporter.ExportToFile(pttMessageListDtos);
        }

    }
}