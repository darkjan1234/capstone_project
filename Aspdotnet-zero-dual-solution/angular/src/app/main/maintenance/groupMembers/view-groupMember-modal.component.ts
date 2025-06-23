import {AppConsts} from "@shared/AppConsts";
import { Component, ViewChild, Injector, Output, EventEmitter } from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { GetGroupMemberForViewDto, GroupMemberDto } from '@shared/service-proxies/service-proxies';
import { AppComponentBase } from '@shared/common/app-component-base';

@Component({
    selector: 'viewGroupMemberModal',
    templateUrl: './view-groupMember-modal.component.html'
})
export class ViewGroupMemberModalComponent extends AppComponentBase {

    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;
    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;

    item: GetGroupMemberForViewDto;


    constructor(
        injector: Injector
    ) {
        super(injector);
        this.item = new GetGroupMemberForViewDto();
        this.item.groupMember = new GroupMemberDto();
    }

    show(item: GetGroupMemberForViewDto): void {
        this.item = item;
        this.active = true;
        this.modal.show();
    }
    
    

    close(): void {
        this.active = false;
        this.modal.hide();
    }
}
