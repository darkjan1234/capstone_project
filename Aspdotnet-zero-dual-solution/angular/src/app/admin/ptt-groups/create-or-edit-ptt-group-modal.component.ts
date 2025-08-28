import { Component, ViewChild, Injector, Output, EventEmitter, OnInit } from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { finalize } from 'rxjs/operators';
import { AppComponentBase } from '@shared/common/app-component-base';
import {
    PttGroupServiceProxy,
    CreateOrEditPttGroupDto,
    PttGroupListDto,
    PttGroupType
} from '@shared/service-proxies/service-proxies';

@Component({
    selector: 'createOrEditPttGroupModal',
    templateUrl: './create-or-edit-ptt-group-modal.component.html',
    styleUrls: ['./create-or-edit-ptt-group-modal.component.less']
})
export class CreateOrEditPttGroupModalComponent extends AppComponentBase implements OnInit {

    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;
    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;
    isEditMode = false;

    pttGroup: CreateOrEditPttGroupDto = new CreateOrEditPttGroupDto();
    availableParentGroups: PttGroupListDto[] = [];
    
    // Enum reference for template
    pttGroupType = PttGroupType;

    constructor(
        injector: Injector,
        private _pttGroupService: PttGroupServiceProxy
    ) {
        super(injector);
    }

    ngOnInit(): void {
        this.loadAvailableParentGroups();
    }

    show(pttGroupId?: number): void {
        this.active = true;
        this.isEditMode = !!pttGroupId;
        
        this.pttGroup = new CreateOrEditPttGroupDto();
        this.pttGroup.isActive = true;
        this.pttGroup.groupType = PttGroupType.User;

        if (pttGroupId) {
            this._pttGroupService.getPttGroupForEdit(pttGroupId).subscribe((result) => {
                this.pttGroup = result.pttGroup;
                this.modal.show();
            });
        } else {
            this.modal.show();
        }
    }

    save(): void {
        this.saving = true;

        this._pttGroupService
            .createOrEdit(this.pttGroup)
            .pipe(
                finalize(() => {
                    this.saving = false;
                })
            )
            .subscribe(() => {
                this.notify.info(this.l('SavedSuccessfully'));
                this.close();
                this.modalSave.emit(null);
            });
    }

    close(): void {
        this.active = false;
        this.modal.hide();
    }

    loadAvailableParentGroups(): void {
        this._pttGroupService.getMyGroups().subscribe((result) => {
            this.availableParentGroups = result.items.filter(g => 
                g.groupType === PttGroupType.Admin || g.groupType === PttGroupType.Mixed
            );
        });
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

    getHierarchyPreview(): any[] {
        if (!this.pttGroup.parentGroupId) {
            return [];
        }

        const parentGroup = this.availableParentGroups.find(g => g.id === this.pttGroup.parentGroupId);
        if (!parentGroup) {
            return [];
        }

        // Build hierarchy path
        const hierarchy = [];
        let currentGroup = parentGroup;
        
        while (currentGroup) {
            hierarchy.unshift({
                name: currentGroup.name,
                groupType: currentGroup.groupType
            });
            
            // Find parent of current group
            currentGroup = this.availableParentGroups.find(g => g.id === currentGroup.parentGroupId);
        }

        return hierarchy;
    }
}
