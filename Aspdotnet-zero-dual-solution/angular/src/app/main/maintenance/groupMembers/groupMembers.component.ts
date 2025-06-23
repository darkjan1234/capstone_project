import {AppConsts} from '@shared/AppConsts';
import { Component, Injector, ViewEncapsulation, ViewChild } from '@angular/core';
import { ActivatedRoute , Router} from '@angular/router';
import { GroupMembersServiceProxy, GroupMemberDto  } from '@shared/service-proxies/service-proxies';
import { NotifyService } from 'abp-ng2-module';
import { AppComponentBase } from '@shared/common/app-component-base';
import { TokenAuthServiceProxy } from '@shared/service-proxies/service-proxies';
import { CreateOrEditGroupMemberModalComponent } from './create-or-edit-groupMember-modal.component';

import { ViewGroupMemberModalComponent } from './view-groupMember-modal.component';
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
    templateUrl: './groupMembers.component.html',
    encapsulation: ViewEncapsulation.None,
    animations: [appModuleAnimation()]
})
export class GroupMembersComponent extends AppComponentBase {
    
    
    @ViewChild('entityTypeHistoryModal', { static: true }) entityTypeHistoryModal: EntityTypeHistoryModalComponent;
    @ViewChild('createOrEditGroupMemberModal', { static: true }) createOrEditGroupMemberModal: CreateOrEditGroupMemberModalComponent;
    @ViewChild('viewGroupMemberModal', { static: true }) viewGroupMemberModal: ViewGroupMemberModalComponent;   
    
    @ViewChild('dataTable', { static: true }) dataTable: Table;
    @ViewChild('paginator', { static: true }) paginator: Paginator;

    advancedFiltersAreShown = false;
    filterText = '';
    maxGroupIdFilter : number;
		maxGroupIdFilterEmpty : number;
		minGroupIdFilter : number;
		minGroupIdFilterEmpty : number;
    pttUserIdFilter = '';
    roleInGroupFilter = '';


    _entityTypeFullName = 'Business.Solutions.Maintenance.GroupMember';
    entityHistoryEnabled = false;



    constructor(
        injector: Injector,
        private _groupMembersServiceProxy: GroupMembersServiceProxy,
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

    getGroupMembers(event?: LazyLoadEvent) {
        if (this.primengTableHelper.shouldResetPaging(event)) {
            this.paginator.changePage(0);
            if (this.primengTableHelper.records &&
                this.primengTableHelper.records.length > 0) {
                return;
            }
        }

        this.primengTableHelper.showLoadingIndicator();

        this._groupMembersServiceProxy.getAll(
            this.filterText,
            this.maxGroupIdFilter == null ? this.maxGroupIdFilterEmpty: this.maxGroupIdFilter,
            this.minGroupIdFilter == null ? this.minGroupIdFilterEmpty: this.minGroupIdFilter,
            this.pttUserIdFilter,
            this.roleInGroupFilter,
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

    createGroupMember(): void {
        this.createOrEditGroupMemberModal.show();        
    }


    showHistory(groupMember: GroupMemberDto): void {
        this.entityTypeHistoryModal.show({
            entityId: groupMember.id.toString(),
            entityTypeFullName: this._entityTypeFullName,
            entityTypeDescription: ''
        });
    }

    deleteGroupMember(groupMember: GroupMemberDto): void {
        this.message.confirm(
            '',
            this.l('AreYouSure'),
            (isConfirmed) => {
                if (isConfirmed) {
                    this._groupMembersServiceProxy.delete(groupMember.id)
                        .subscribe(() => {
                            this.reloadPage();
                            this.notify.success(this.l('SuccessfullyDeleted'));
                        });
                }
            }
        );
    }

    exportToExcel(): void {
        this._groupMembersServiceProxy.getGroupMembersToExcel(
        this.filterText,
            this.maxGroupIdFilter == null ? this.maxGroupIdFilterEmpty: this.maxGroupIdFilter,
            this.minGroupIdFilter == null ? this.minGroupIdFilterEmpty: this.minGroupIdFilter,
            this.pttUserIdFilter,
            this.roleInGroupFilter,
        )
        .subscribe(result => {
            this._fileDownloadService.downloadTempFile(result);
         });
    }
    
    
    
    
    

    resetFilters(): void {
        this.filterText = '';
            this.maxGroupIdFilter = this.maxGroupIdFilterEmpty;
		this.minGroupIdFilter = this.maxGroupIdFilterEmpty;
    this.pttUserIdFilter = '';
    this.roleInGroupFilter = '';

        this.getGroupMembers();
    }
}
