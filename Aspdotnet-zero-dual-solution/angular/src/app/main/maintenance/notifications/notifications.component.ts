import {AppConsts} from '@shared/AppConsts';
import { Component, Injector, ViewEncapsulation, ViewChild } from '@angular/core';
import { ActivatedRoute , Router} from '@angular/router';
import { NotificationsServiceProxy, NotificationDto  } from '@shared/service-proxies/service-proxies';
import { NotifyService } from 'abp-ng2-module';
import { AppComponentBase } from '@shared/common/app-component-base';
import { TokenAuthServiceProxy } from '@shared/service-proxies/service-proxies';
import { CreateOrEditNotificationModalComponent } from './create-or-edit-notification-modal.component';

import { ViewNotificationModalComponent } from './view-notification-modal.component';
import { appModuleAnimation } from '@shared/animations/routerTransition';
import { Table } from 'primeng/table';
import { Paginator } from 'primeng/paginator';
import { LazyLoadEvent } from 'primeng/api';
import { FileDownloadService } from '@shared/utils/file-download.service';
import { filter as _filter } from 'lodash-es';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';

@Component({
    templateUrl: './notifications.component.html',
    encapsulation: ViewEncapsulation.None,
    animations: [appModuleAnimation()]
})
export class NotificationsComponent extends AppComponentBase {
    
    
    @ViewChild('createOrEditNotificationModal', { static: true }) createOrEditNotificationModal: CreateOrEditNotificationModalComponent;
    @ViewChild('viewNotificationModal', { static: true }) viewNotificationModal: ViewNotificationModalComponent;   
    
    @ViewChild('dataTable', { static: true }) dataTable: Table;
    @ViewChild('paginator', { static: true }) paginator: Paginator;

    advancedFiltersAreShown = false;
    filterText = '';
    maxUserIdFilter : number;
		maxUserIdFilterEmpty : number;
		minUserIdFilter : number;
		minUserIdFilterEmpty : number;
    messageFilter = '';
    isreadFilter = -1;






    constructor(
        injector: Injector,
        private _notificationsServiceProxy: NotificationsServiceProxy,
        private _notifyService: NotifyService,
        private _tokenAuth: TokenAuthServiceProxy,
        private _activatedRoute: ActivatedRoute,
        private _fileDownloadService: FileDownloadService,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }

    getNotifications(event?: LazyLoadEvent) {
        if (this.primengTableHelper.shouldResetPaging(event)) {
            this.paginator.changePage(0);
            if (this.primengTableHelper.records &&
                this.primengTableHelper.records.length > 0) {
                return;
            }
        }

        this.primengTableHelper.showLoadingIndicator();

        this._notificationsServiceProxy.getAll(
            this.filterText,
            this.maxUserIdFilter == null ? this.maxUserIdFilterEmpty: this.maxUserIdFilter,
            this.minUserIdFilter == null ? this.minUserIdFilterEmpty: this.minUserIdFilter,
            this.messageFilter,
            this.isreadFilter,
            this.primengTableHelper.getSorting(this.dataTable),
            this.primengTableHelper.getSkipCount(this.paginator, event),
            this.primengTableHelper.getMaxResultCount(this.paginator, event)
        ).subscribe(result => {
            this.primengTableHelper.totalRecordsCount = result.totalCount;
            this.primengTableHelper.records = result.items;
            this.primengTableHelper.hideLoadingIndicator();
        });
    }

    reloadPage(): void {
        this.paginator.changePage(this.paginator.getPage());
    }

    createNotification(): void {
        this.createOrEditNotificationModal.show();        
    }


    deleteNotification(notification: NotificationDto): void {
        this.message.confirm(
            '',
            this.l('AreYouSure'),
            (isConfirmed) => {
                if (isConfirmed) {
                    this._notificationsServiceProxy.delete(notification.id)
                        .subscribe(() => {
                            this.reloadPage();
                            this.notify.success(this.l('SuccessfullyDeleted'));
                        });
                }
            }
        );
    }

    exportToExcel(): void {
        this._notificationsServiceProxy.getNotificationsToExcel(
        this.filterText,
            this.maxUserIdFilter == null ? this.maxUserIdFilterEmpty: this.maxUserIdFilter,
            this.minUserIdFilter == null ? this.minUserIdFilterEmpty: this.minUserIdFilter,
            this.messageFilter,
            this.isreadFilter,
        )
        .subscribe(result => {
            this._fileDownloadService.downloadTempFile(result);
         });
    }
    
    
    
    
    

    resetFilters(): void {
        this.filterText = '';
            this.maxUserIdFilter = this.maxUserIdFilterEmpty;
		this.minUserIdFilter = this.maxUserIdFilterEmpty;
    this.messageFilter = '';
    this.isreadFilter = -1;

        this.getNotifications();
    }
}
