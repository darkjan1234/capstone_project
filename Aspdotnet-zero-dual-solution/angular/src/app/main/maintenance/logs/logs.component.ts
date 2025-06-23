import {AppConsts} from '@shared/AppConsts';
import { Component, Injector, ViewEncapsulation, ViewChild } from '@angular/core';
import { ActivatedRoute , Router} from '@angular/router';
import { LogsServiceProxy, LogDto  } from '@shared/service-proxies/service-proxies';
import { NotifyService } from 'abp-ng2-module';
import { AppComponentBase } from '@shared/common/app-component-base';
import { TokenAuthServiceProxy } from '@shared/service-proxies/service-proxies';
import { CreateOrEditLogModalComponent } from './create-or-edit-log-modal.component';

import { ViewLogModalComponent } from './view-log-modal.component';
import { appModuleAnimation } from '@shared/animations/routerTransition';
import { Table } from 'primeng/table';
import { Paginator } from 'primeng/paginator';
import { LazyLoadEvent } from 'primeng/api';
import { FileDownloadService } from '@shared/utils/file-download.service';
import { EntityTypeHistoryModalComponent } from '@app/shared/common/entityHistory/entity-type-history-modal.component';
import { filter as _filter } from 'lodash-es';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';

@Component({
    templateUrl: './logs.component.html',
    encapsulation: ViewEncapsulation.None,
    animations: [appModuleAnimation()]
})
export class LogsComponent extends AppComponentBase {
    
    
    @ViewChild('entityTypeHistoryModal', { static: true }) entityTypeHistoryModal: EntityTypeHistoryModalComponent;
    @ViewChild('createOrEditLogModal', { static: true }) createOrEditLogModal: CreateOrEditLogModalComponent;
    @ViewChild('viewLogModal', { static: true }) viewLogModal: ViewLogModalComponent;   
    
    @ViewChild('dataTable', { static: true }) dataTable: Table;
    @ViewChild('paginator', { static: true }) paginator: Paginator;

    advancedFiltersAreShown = false;
    filterText = '';
    maxUserIdFilter : number;
		maxUserIdFilterEmpty : number;
		minUserIdFilter : number;
		minUserIdFilterEmpty : number;
    activityFilter = '';
    logLevelFilter = '';


    _entityTypeFullName = 'Business.Solutions.Maintenance.Log';
    entityHistoryEnabled = false;



    constructor(
        injector: Injector,
        private _logsServiceProxy: LogsServiceProxy,
        private _notifyService: NotifyService,
        private _tokenAuth: TokenAuthServiceProxy,
        private _activatedRoute: ActivatedRoute,
        private _fileDownloadService: FileDownloadService,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }

    ngOnInit(): void {
        this.entityHistoryEnabled = this.setIsEntityHistoryEnabled();
    }

    private setIsEntityHistoryEnabled(): boolean {
        let customSettings = (abp as any).custom;
        return this.isGrantedAny('Pages.Administration.AuditLogs') && customSettings.EntityHistory && customSettings.EntityHistory.isEnabled && _filter(customSettings.EntityHistory.enabledEntities, entityType => entityType === this._entityTypeFullName).length === 1;
    }

    getLogs(event?: LazyLoadEvent) {
        if (this.primengTableHelper.shouldResetPaging(event)) {
            this.paginator.changePage(0);
            if (this.primengTableHelper.records &&
                this.primengTableHelper.records.length > 0) {
                return;
            }
        }

        this.primengTableHelper.showLoadingIndicator();

        this._logsServiceProxy.getAll(
            this.filterText,
            this.maxUserIdFilter == null ? this.maxUserIdFilterEmpty: this.maxUserIdFilter,
            this.minUserIdFilter == null ? this.minUserIdFilterEmpty: this.minUserIdFilter,
            this.activityFilter,
            this.logLevelFilter,
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

    createLog(): void {
        this.createOrEditLogModal.show();        
    }


    showHistory(log: LogDto): void {
        this.entityTypeHistoryModal.show({
            entityId: log.id.toString(),
            entityTypeFullName: this._entityTypeFullName,
            entityTypeDescription: ''
        });
    }

    deleteLog(log: LogDto): void {
        this.message.confirm(
            '',
            this.l('AreYouSure'),
            (isConfirmed) => {
                if (isConfirmed) {
                    this._logsServiceProxy.delete(log.id)
                        .subscribe(() => {
                            this.reloadPage();
                            this.notify.success(this.l('SuccessfullyDeleted'));
                        });
                }
            }
        );
    }

    exportToExcel(): void {
        this._logsServiceProxy.getLogsToExcel(
        this.filterText,
            this.maxUserIdFilter == null ? this.maxUserIdFilterEmpty: this.maxUserIdFilter,
            this.minUserIdFilter == null ? this.minUserIdFilterEmpty: this.minUserIdFilter,
            this.activityFilter,
            this.logLevelFilter,
        )
        .subscribe(result => {
            this._fileDownloadService.downloadTempFile(result);
         });
    }
    
    
    
    
    

    resetFilters(): void {
        this.filterText = '';
            this.maxUserIdFilter = this.maxUserIdFilterEmpty;
		this.minUserIdFilter = this.maxUserIdFilterEmpty;
    this.activityFilter = '';
    this.logLevelFilter = '';

        this.getLogs();
    }
}
