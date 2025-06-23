import {AppConsts} from "@shared/AppConsts";
import { Component, ViewChild, Injector, Output, EventEmitter } from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { GetPTTMessageForViewDto, PTTMessageDto } from '@shared/service-proxies/service-proxies';
import { AppComponentBase } from '@shared/common/app-component-base';

@Component({
    selector: 'viewPTTMessageModal',
    templateUrl: './view-pttMessage-modal.component.html'
})
export class ViewPTTMessageModalComponent extends AppComponentBase {

    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;
    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;

    item: GetPTTMessageForViewDto;


    constructor(
        injector: Injector
    ) {
        super(injector);
        this.item = new GetPTTMessageForViewDto();
        this.item.pttMessage = new PTTMessageDto();
    }

    show(item: GetPTTMessageForViewDto): void {
        this.item = item;
        this.active = true;
        this.modal.show();
    }
    
    

    close(): void {
        this.active = false;
        this.modal.hide();
    }
}
