import {AppConsts} from "@shared/AppConsts";
import { Component, ViewChild, Injector, Output, EventEmitter } from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { GetCommunicationHistoryForViewDto, CommunicationHistoryDto } from '@shared/service-proxies/service-proxies';
import { AppComponentBase } from '@shared/common/app-component-base';

@Component({
    selector: 'viewCommunicationHistoryModal',
    templateUrl: './view-communicationHistory-modal.component.html'
})
export class ViewCommunicationHistoryModalComponent extends AppComponentBase {

    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;
    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;

    item: GetCommunicationHistoryForViewDto;


    constructor(
        injector: Injector
    ) {
        super(injector);
        this.item = new GetCommunicationHistoryForViewDto();
        this.item.communicationHistory = new CommunicationHistoryDto();
    }

    show(item: GetCommunicationHistoryForViewDto): void {
        this.item = item;
        this.active = true;
        this.modal.show();
    }
    
    

    close(): void {
        this.active = false;
        this.modal.hide();
    }
}
