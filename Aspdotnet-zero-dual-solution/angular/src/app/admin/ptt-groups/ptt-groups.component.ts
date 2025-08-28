import { Component, Injector, ViewChild, OnInit } from '@angular/core';
import { appModuleAnimation } from '@shared/animations/routerTransition';
import { AppComponentBase } from '@shared/common/app-component-base';
import { PttGroupServiceProxy, PttGroupListDto, PttGroupHierarchyDto, GetPttGroupsInput, PttGroupType } from '@shared/service-proxies/ptt-group-service-proxy';
// import { PagedListingComponentBase, PagedRequestDto } from '@shared/common/paged-listing-component-base';
import { CreateOrEditPttGroupModalComponent } from './create-or-edit-ptt-group-modal.component';
import { GroupMembersModalComponent } from './group-members-modal.component';
import { finalize } from 'rxjs/operators';

class PagedPttGroupsRequestDto {
    keyword: string;
    groupType: PttGroupType | undefined;
    isActive: boolean | undefined;
    maxResultCount: number = 10;
    skipCount: number = 0;
    sorting?: string;
}

@Component({
    templateUrl: './ptt-groups.component.html',
    styleUrls: ['./ptt-groups.component.css'],
    animations: [appModuleAnimation()]
})
export class PttGroupsComponent extends AppComponentBase implements OnInit {

    @ViewChild('createOrEditPttGroupModal', { static: true }) createOrEditPttGroupModal: CreateOrEditPttGroupModalComponent;
    @ViewChild('groupMembersModal', { static: true }) groupMembersModal: GroupMembersModalComponent;

    pttGroups: any = { items: [], totalCount: 0 };
    groupHierarchy: PttGroupHierarchyDto[] = [];
    filterText = '';
    selectedGroupType: string = '';
    selectedActiveStatus: string = '';
    request: PagedPttGroupsRequestDto = new PagedPttGroupsRequestDto();
    loading = false;

    // Enum references for template
    pttGroupType = PttGroupType;

    constructor(
        injector: Injector,
        private _pttGroupService: PttGroupServiceProxy
    ) {
        super(injector);
    }

    ngOnInit(): void {
        this.getPttGroups();
        this.getGroupHierarchy();
    }

    getPttGroups(pageNumber?: number): void {
        this.loading = true;
        this.request.skipCount = pageNumber ? (pageNumber - 1) * this.request.maxResultCount : 0;
        this.request.keyword = this.filterText;
        this.request.groupType = this.selectedGroupType ? parseInt(this.selectedGroupType) : undefined;
        this.request.isActive = this.selectedActiveStatus ? this.selectedActiveStatus === 'true' : undefined;

        this._pttGroupService
            .getPttGroups({
                filter: this.request.keyword,
                groupType: this.request.groupType,
                isActive: this.request.isActive,
                maxResultCount: this.request.maxResultCount,
                skipCount: this.request.skipCount,
                sorting: this.request.sorting
            })
            .pipe(
                finalize(() => {
                    this.loading = false;
                })
            )
            .subscribe((result) => {
                this.pttGroups = result;
            });
    }

    refresh(): void {
        this.getPttGroups();
    }

    showPaging(result: any, pageNumber: number): void {
        // This method is for compatibility with pagination
    }

    getDataPage(pageNumber: number): void {
        this.getPttGroups(pageNumber);
    }

    delete(pttGroup: PttGroupListDto): void {
        abp.message.confirm(
            this.l('PttGroupDeleteWarningMessage', pttGroup.name),
            undefined,
            (result: boolean) => {
                if (result) {
                    this._pttGroupService.delete(pttGroup.id).subscribe(() => {
                        abp.notify.success(this.l('SuccessfullyDeleted'));
                        this.refresh();
                        this.getGroupHierarchy();
                    });
                }
            }
        );
    }

    createPttGroup(): void {
        this.createOrEditPttGroupModal.show();
    }

    editPttGroup(pttGroup: PttGroupListDto): void {
        this.createOrEditPttGroupModal.show(pttGroup.id);
    }

    viewGroupMembers(pttGroup: PttGroupListDto): void {
        this.groupMembersModal.show(pttGroup.id, pttGroup.name);
    }

    deletePttGroup(pttGroup: PttGroupListDto): void {
        this.delete(pttGroup);
    }

    exportToExcel(): void {
        // Implement export functionality
        abp.notify.info(this.l('ExportToExcelFeatureComingSoon'));
    }

    getGroupHierarchy(): void {
        this._pttGroupService.getGroupHierarchy().subscribe((result) => {
            this.groupHierarchy = result.items;
        });
    }

    selectGroup(group: PttGroupHierarchyDto): void {
        // Handle group selection - could navigate to group details
        console.log('Selected group:', group);
    }

    getGroupTypeClass(groupType: PttGroupType): string {
        switch (groupType) {
            case PttGroupType.Admin:
                return 'group-admin';
            case PttGroupType.User:
                return 'group-user';
            case PttGroupType.Mixed:
                return 'group-mixed';
            default:
                return '';
        }
    }

    getGroupIcon(groupType: PttGroupType): string {
        switch (groupType) {
            case PttGroupType.Admin:
                return 'fa-shield-alt';
            case PttGroupType.User:
                return 'fa-users';
            case PttGroupType.Mixed:
                return 'fa-user-friends';
            default:
                return 'fa-circle';
        }
    }

    getGroupTypeBadgeClass(groupType: PttGroupType): string {
        switch (groupType) {
            case PttGroupType.Admin:
                return 'badge-light-danger';
            case PttGroupType.User:
                return 'badge-light-primary';
            case PttGroupType.Mixed:
                return 'badge-light-warning';
            default:
                return 'badge-light-secondary';
        }
    }

    getGroupTypeText(groupType: PttGroupType): string {
        switch (groupType) {
            case PttGroupType.Admin:
                return this.l('AdminGroup');
            case PttGroupType.User:
                return this.l('UserGroup');
            case PttGroupType.Mixed:
                return this.l('MixedGroup');
            default:
                return '';
        }
    }

    getPttGroups(event?: any): void {
        if (event) {
            this.getDataPage(event);
        } else {
            this.getDataPage(1);
        }
    }
}
