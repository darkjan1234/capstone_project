import { Component, ViewChild, Injector, Output, EventEmitter, OnInit, ElementRef} from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { finalize } from 'rxjs/operators';
import { PTTMessagesServiceProxy, CreateOrEditPTTMessageDto } from '@shared/service-proxies/service-proxies';
import { AppComponentBase } from '@shared/common/app-component-base';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';



@Component({
    selector: 'createOrEditPTTMessageModal',
    templateUrl: './create-or-edit-pttMessage-modal.component.html'
})
export class CreateOrEditPTTMessageModalComponent extends AppComponentBase implements OnInit{
   
    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;

    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;

    pttMessage: CreateOrEditPTTMessageDto = new CreateOrEditPTTMessageDto();




    constructor(
        injector: Injector,
        private _pttMessagesServiceProxy: PTTMessagesServiceProxy,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }
    
    show(pttMessageId?: string): void {
    

        if (!pttMessageId) {
            this.pttMessage = new CreateOrEditPTTMessageDto();
            this.pttMessage.id = pttMessageId;


            this.active = true;
            this.modal.show();
        } else {
            this._pttMessagesServiceProxy.getPTTMessageForEdit(pttMessageId).subscribe(result => {
                this.pttMessage = result.pttMessage;



                this.active = true;
                this.modal.show();
            });
        }
        
        
    }

    save(): void {
            this.saving = true;
            
			
			
            this._pttMessagesServiceProxy.createOrEdit(this.pttMessage)
             .pipe(finalize(() => { this.saving = false;}))
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
    
     ngOnInit(): void {
        
     }    
}
