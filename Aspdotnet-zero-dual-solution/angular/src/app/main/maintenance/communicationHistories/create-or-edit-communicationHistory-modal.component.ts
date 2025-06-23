import { Component, ViewChild, Injector, Output, EventEmitter, OnInit, ElementRef} from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { finalize } from 'rxjs/operators';
import { CommunicationHistoriesServiceProxy, CreateOrEditCommunicationHistoryDto } from '@shared/service-proxies/service-proxies';
import { AppComponentBase } from '@shared/common/app-component-base';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';



@Component({
    selector: 'createOrEditCommunicationHistoryModal',
    templateUrl: './create-or-edit-communicationHistory-modal.component.html'
})
export class CreateOrEditCommunicationHistoryModalComponent extends AppComponentBase implements OnInit{
   
    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;

    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;

    communicationHistory: CreateOrEditCommunicationHistoryDto = new CreateOrEditCommunicationHistoryDto();




    constructor(
        injector: Injector,
        private _communicationHistoriesServiceProxy: CommunicationHistoriesServiceProxy,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }
    
    show(communicationHistoryId?: string): void {
    

        if (!communicationHistoryId) {
            this.communicationHistory = new CreateOrEditCommunicationHistoryDto();
            this.communicationHistory.id = communicationHistoryId;


            this.active = true;
            this.modal.show();
        } else {
            this._communicationHistoriesServiceProxy.getCommunicationHistoryForEdit(communicationHistoryId).subscribe(result => {
                this.communicationHistory = result.communicationHistory;



                this.active = true;
                this.modal.show();
            });
        }
        
        
    }

    save(): void {
            this.saving = true;
            
			
			
            this._communicationHistoriesServiceProxy.createOrEdit(this.communicationHistory)
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
