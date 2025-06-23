import {AppConsts} from '@shared/AppConsts';
import { Component, Injector, ViewEncapsulation, ViewChild } from '@angular/core';
import { ActivatedRoute , Router} from '@angular/router';
import { PttUsersServiceProxy, PttUserDto  } from '@shared/service-proxies/service-proxies';
import { NotifyService } from 'abp-ng2-module';
import { AppComponentBase } from '@shared/common/app-component-base';
import { TokenAuthServiceProxy } from '@shared/service-proxies/service-proxies';
import { CreateOrEditPttUserModalComponent } from './create-or-edit-pttUser-modal.component';

import { ViewPttUserModalComponent } from './view-pttUser-modal.component';
import { appModuleAnimation } from '@shared/animations/routerTransition';
import { Table } from 'primeng/table';
import { Paginator } from 'primeng/paginator';
import { LazyLoadEvent } from 'primeng/api';
import { FileDownloadService } from '@shared/utils/file-download.service';
import { filter as _filter } from 'lodash-es';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';

@Component({
    templateUrl: './pttUsers.component.html',
    encapsulation: ViewEncapsulation.None,
    animations: [appModuleAnimation()]
})
export class PttUsersComponent extends AppComponentBase {
    
    
    @ViewChild('createOrEditPttUserModal', { static: true }) createOrEditPttUserModal: CreateOrEditPttUserModalComponent;
    @ViewChild('viewPttUserModal', { static: true }) viewPttUserModal: ViewPttUserModalComponent;   
    
    @ViewChild('dataTable', { static: true }) dataTable: Table;
    @ViewChild('paginator', { static: true }) paginator: Paginator;

    advancedFiltersAreShown = false;
    filterText = '';
    fullNameFilter = '';
    emailFilter = '';
    passwordHashFilter = '';
    roleFilter = '';
    statusFilter = -1;






    constructor(
        injector: Injector,
        private _pttUsersServiceProxy: PttUsersServiceProxy,
        private _notifyService: NotifyService,
        private _tokenAuth: TokenAuthServiceProxy,
        private _activatedRoute: ActivatedRoute,
        private _fileDownloadService: FileDownloadService,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }

    getPttUsers(event?: LazyLoadEvent) {
        if (this.primengTableHelper.shouldResetPaging(event)) {
            this.paginator.changePage(0);
            if (this.primengTableHelper.records &&
                this.primengTableHelper.records.length > 0) {
                return;
            }
        }

        this.primengTableHelper.showLoadingIndicator();

        this._pttUsersServiceProxy.getAll(
            this.filterText,
            this.fullNameFilter,
            this.emailFilter,
            this.passwordHashFilter,
            this.roleFilter,
            this.statusFilter,
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

    createPttUser(): void {
        this.createOrEditPttUserModal.show();        
    }


    deletePttUser(pttUser: PttUserDto): void {
        this.message.confirm(
            '',
            this.l('AreYouSure'),
            (isConfirmed) => {
                if (isConfirmed) {
                    this._pttUsersServiceProxy.delete(pttUser.id)
                        .subscribe(() => {
                            this.reloadPage();
                            this.notify.success(this.l('SuccessfullyDeleted'));
                        });
                }
            }
        );
    }

    exportToExcel(): void {
        this._pttUsersServiceProxy.getPttUsersToExcel(
        this.filterText,
            this.fullNameFilter,
            this.emailFilter,
            this.passwordHashFilter,
            this.roleFilter,
            this.statusFilter,
        )
        .subscribe(result => {
            this._fileDownloadService.downloadTempFile(result);
         });
    }
    
    
    
    
    

    resetFilters(): void {
        this.filterText = '';
            this.fullNameFilter = '';
    this.emailFilter = '';
    this.passwordHashFilter = '';
    this.roleFilter = '';
    this.statusFilter = -1;

        this.getPttUsers();
    }
}
