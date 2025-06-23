import {AppConsts} from '@shared/AppConsts';
import { Component, Injector, ViewEncapsulation, ViewChild } from '@angular/core';
import { ActivatedRoute , Router} from '@angular/router';
import { PTTMessagesServiceProxy, PTTMessageDto  } from '@shared/service-proxies/service-proxies';
import { NotifyService } from 'abp-ng2-module';
import { AppComponentBase } from '@shared/common/app-component-base';
import { TokenAuthServiceProxy } from '@shared/service-proxies/service-proxies';
import { CreateOrEditPTTMessageModalComponent } from './create-or-edit-pttMessage-modal.component';

import { ViewPTTMessageModalComponent } from './view-pttMessage-modal.component';
import { appModuleAnimation } from '@shared/animations/routerTransition';
import { Table } from 'primeng/table';
import { Paginator } from 'primeng/paginator';
import { LazyLoadEvent } from 'primeng/api';
import { FileDownloadService } from '@shared/utils/file-download.service';
import { filter as _filter } from 'lodash-es';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';

@Component({
    templateUrl: './pttMessages.component.html',
    encapsulation: ViewEncapsulation.None,
    animations: [appModuleAnimation()]
})
export class PTTMessagesComponent extends AppComponentBase {
    
    
    @ViewChild('createOrEditPTTMessageModal', { static: true }) createOrEditPTTMessageModal: CreateOrEditPTTMessageModalComponent;
    @ViewChild('viewPTTMessageModal', { static: true }) viewPTTMessageModal: ViewPTTMessageModalComponent;   
    
    @ViewChild('dataTable', { static: true }) dataTable: Table;
    @ViewChild('paginator', { static: true }) paginator: Paginator;

    advancedFiltersAreShown = false;
    filterText = '';
    maxSenderIdFilter : number;
		maxSenderIdFilterEmpty : number;
		minSenderIdFilter : number;
		minSenderIdFilterEmpty : number;
    maxReceiverIdFilter : number;
		maxReceiverIdFilterEmpty : number;
		minReceiverIdFilter : number;
		minReceiverIdFilterEmpty : number;
    maxGroupIdFilter : number;
		maxGroupIdFilterEmpty : number;
		minGroupIdFilter : number;
		minGroupIdFilterEmpty : number;
    audioPathFilter = '';
    maxDurationSecondsFilter : number;
		maxDurationSecondsFilterEmpty : number;
		minDurationSecondsFilter : number;
		minDurationSecondsFilterEmpty : number;






    constructor(
        injector: Injector,
        private _pttMessagesServiceProxy: PTTMessagesServiceProxy,
        private _notifyService: NotifyService,
        private _tokenAuth: TokenAuthServiceProxy,
        private _activatedRoute: ActivatedRoute,
        private _fileDownloadService: FileDownloadService,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }

    getPTTMessages(event?: LazyLoadEvent) {
        if (this.primengTableHelper.shouldResetPaging(event)) {
            this.paginator.changePage(0);
            if (this.primengTableHelper.records &&
                this.primengTableHelper.records.length > 0) {
                return;
            }
        }

        this.primengTableHelper.showLoadingIndicator();

        this._pttMessagesServiceProxy.getAll(
            this.filterText,
            this.maxSenderIdFilter == null ? this.maxSenderIdFilterEmpty: this.maxSenderIdFilter,
            this.minSenderIdFilter == null ? this.minSenderIdFilterEmpty: this.minSenderIdFilter,
            this.maxReceiverIdFilter == null ? this.maxReceiverIdFilterEmpty: this.maxReceiverIdFilter,
            this.minReceiverIdFilter == null ? this.minReceiverIdFilterEmpty: this.minReceiverIdFilter,
            this.maxGroupIdFilter == null ? this.maxGroupIdFilterEmpty: this.maxGroupIdFilter,
            this.minGroupIdFilter == null ? this.minGroupIdFilterEmpty: this.minGroupIdFilter,
            this.audioPathFilter,
            this.maxDurationSecondsFilter == null ? this.maxDurationSecondsFilterEmpty: this.maxDurationSecondsFilter,
            this.minDurationSecondsFilter == null ? this.minDurationSecondsFilterEmpty: this.minDurationSecondsFilter,
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

    createPTTMessage(): void {
        this.createOrEditPTTMessageModal.show();        
    }


    deletePTTMessage(pttMessage: PTTMessageDto): void {
        this.message.confirm(
            '',
            this.l('AreYouSure'),
            (isConfirmed) => {
                if (isConfirmed) {
                    this._pttMessagesServiceProxy.delete(pttMessage.id)
                        .subscribe(() => {
                            this.reloadPage();
                            this.notify.success(this.l('SuccessfullyDeleted'));
                        });
                }
            }
        );
    }

    exportToExcel(): void {
        this._pttMessagesServiceProxy.getPTTMessagesToExcel(
        this.filterText,
            this.maxSenderIdFilter == null ? this.maxSenderIdFilterEmpty: this.maxSenderIdFilter,
            this.minSenderIdFilter == null ? this.minSenderIdFilterEmpty: this.minSenderIdFilter,
            this.maxReceiverIdFilter == null ? this.maxReceiverIdFilterEmpty: this.maxReceiverIdFilter,
            this.minReceiverIdFilter == null ? this.minReceiverIdFilterEmpty: this.minReceiverIdFilter,
            this.maxGroupIdFilter == null ? this.maxGroupIdFilterEmpty: this.maxGroupIdFilter,
            this.minGroupIdFilter == null ? this.minGroupIdFilterEmpty: this.minGroupIdFilter,
            this.audioPathFilter,
            this.maxDurationSecondsFilter == null ? this.maxDurationSecondsFilterEmpty: this.maxDurationSecondsFilter,
            this.minDurationSecondsFilter == null ? this.minDurationSecondsFilterEmpty: this.minDurationSecondsFilter,
        )
        .subscribe(result => {
            this._fileDownloadService.downloadTempFile(result);
         });
    }
    
    
    
    
    

    resetFilters(): void {
        this.filterText = '';
            this.maxSenderIdFilter = this.maxSenderIdFilterEmpty;
		this.minSenderIdFilter = this.maxSenderIdFilterEmpty;
    this.maxReceiverIdFilter = this.maxReceiverIdFilterEmpty;
		this.minReceiverIdFilter = this.maxReceiverIdFilterEmpty;
    this.maxGroupIdFilter = this.maxGroupIdFilterEmpty;
		this.minGroupIdFilter = this.maxGroupIdFilterEmpty;
    this.audioPathFilter = '';
    this.maxDurationSecondsFilter = this.maxDurationSecondsFilterEmpty;
		this.minDurationSecondsFilter = this.maxDurationSecondsFilterEmpty;

        this.getPTTMessages();
    }
}
