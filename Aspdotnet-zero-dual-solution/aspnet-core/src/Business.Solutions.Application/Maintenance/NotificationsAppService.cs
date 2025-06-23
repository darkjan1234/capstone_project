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
    [AbpAuthorize(AppPermissions.Pages_Notifications)]
    public class NotificationsAppService : SolutionsAppServiceBase, INotificationsAppService
    {
        private readonly IRepository<Notification, Guid> _notificationRepository;
        private readonly INotificationsExcelExporter _notificationsExcelExporter;

        public NotificationsAppService(IRepository<Notification, Guid> notificationRepository, INotificationsExcelExporter notificationsExcelExporter)
        {
            _notificationRepository = notificationRepository;
            _notificationsExcelExporter = notificationsExcelExporter;

        }

        public virtual async Task<PagedResultDto<GetNotificationForViewDto>> GetAll(GetAllNotificationsInput input)
        {

            var filteredNotifications = _notificationRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.Message.Contains(input.Filter))
                        .WhereIf(input.MinUserIdFilter != null, e => e.UserId >= input.MinUserIdFilter)
                        .WhereIf(input.MaxUserIdFilter != null, e => e.UserId <= input.MaxUserIdFilter)
                        .WhereIf(!string.IsNullOrWhiteSpace(input.MessageFilter), e => e.Message.Contains(input.MessageFilter))
                        .WhereIf(input.IsreadFilter.HasValue && input.IsreadFilter > -1, e => (input.IsreadFilter == 1 && e.Isread) || (input.IsreadFilter == 0 && !e.Isread));

            var pagedAndFilteredNotifications = filteredNotifications
                .OrderBy(input.Sorting ?? "id asc")
                .PageBy(input);

            var notifications = from o in pagedAndFilteredNotifications
                                select new
                                {

                                    o.UserId,
                                    o.Message,
                                    o.Isread,
                                    Id = o.Id
                                };

            var totalCount = await filteredNotifications.CountAsync();

            var dbList = await notifications.ToListAsync();
            var results = new List<GetNotificationForViewDto>();

            foreach (var o in dbList)
            {
                var res = new GetNotificationForViewDto()
                {
                    Notification = new NotificationDto
                    {

                        UserId = o.UserId,
                        Message = o.Message,
                        Isread = o.Isread,
                        Id = o.Id,
                    }
                };

                results.Add(res);
            }

            return new PagedResultDto<GetNotificationForViewDto>(
                totalCount,
                results
            );

        }

        public virtual async Task<GetNotificationForViewDto> GetNotificationForView(Guid id)
        {
            var notification = await _notificationRepository.GetAsync(id);

            var output = new GetNotificationForViewDto { Notification = ObjectMapper.Map<NotificationDto>(notification) };

            return output;
        }

        [AbpAuthorize(AppPermissions.Pages_Notifications_Edit)]
        public virtual async Task<GetNotificationForEditOutput> GetNotificationForEdit(EntityDto<Guid> input)
        {
            var notification = await _notificationRepository.FirstOrDefaultAsync(input.Id);

            var output = new GetNotificationForEditOutput { Notification = ObjectMapper.Map<CreateOrEditNotificationDto>(notification) };

            return output;
        }

        public virtual async Task CreateOrEdit(CreateOrEditNotificationDto input)
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

        [AbpAuthorize(AppPermissions.Pages_Notifications_Create)]
        protected virtual async Task Create(CreateOrEditNotificationDto input)
        {
            var notification = ObjectMapper.Map<Notification>(input);

            if (AbpSession.TenantId != null)
            {
                notification.TenantId = (int?)AbpSession.TenantId;
            }

            await _notificationRepository.InsertAsync(notification);

        }

        [AbpAuthorize(AppPermissions.Pages_Notifications_Edit)]
        protected virtual async Task Update(CreateOrEditNotificationDto input)
        {
            var notification = await _notificationRepository.FirstOrDefaultAsync((Guid)input.Id);
            ObjectMapper.Map(input, notification);

        }

        [AbpAuthorize(AppPermissions.Pages_Notifications_Delete)]
        public virtual async Task Delete(EntityDto<Guid> input)
        {
            await _notificationRepository.DeleteAsync(input.Id);
        }

        public virtual async Task<FileDto> GetNotificationsToExcel(GetAllNotificationsForExcelInput input)
        {

            var filteredNotifications = _notificationRepository.GetAll()
                        .WhereIf(!string.IsNullOrWhiteSpace(input.Filter), e => false || e.Message.Contains(input.Filter))
                        .WhereIf(input.MinUserIdFilter != null, e => e.UserId >= input.MinUserIdFilter)
                        .WhereIf(input.MaxUserIdFilter != null, e => e.UserId <= input.MaxUserIdFilter)
                        .WhereIf(!string.IsNullOrWhiteSpace(input.MessageFilter), e => e.Message.Contains(input.MessageFilter))
                        .WhereIf(input.IsreadFilter.HasValue && input.IsreadFilter > -1, e => (input.IsreadFilter == 1 && e.Isread) || (input.IsreadFilter == 0 && !e.Isread));

            var query = (from o in filteredNotifications
                         select new GetNotificationForViewDto()
                         {
                             Notification = new NotificationDto
                             {
                                 UserId = o.UserId,
                                 Message = o.Message,
                                 Isread = o.Isread,
                                 Id = o.Id
                             }
                         });

            var notificationListDtos = await query.ToListAsync();

            return _notificationsExcelExporter.ExportToFile(notificationListDtos);
        }

    }
}