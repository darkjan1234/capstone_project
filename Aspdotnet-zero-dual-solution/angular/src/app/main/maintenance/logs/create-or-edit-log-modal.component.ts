import { Component, ViewChild, Injector, Output, EventEmitter, OnInit, ElementRef} from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { finalize } from 'rxjs/operators';
import { LogsServiceProxy, CreateOrEditLogDto } from '@shared/service-proxies/service-proxies';
import { AppComponentBase } from '@shared/common/app-component-base';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';



@Component({
    selector: 'createOrEditLogModal',
    templateUrl: './create-or-edit-log-modal.component.html'
})
export class CreateOrEditLogModalComponent extends AppComponentBase implements OnInit{
   
    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;

    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;

    log: CreateOrEditLogDto = new CreateOrEditLogDto();




    constructor(
        injector: Injector,
        private _logsServiceProxy: LogsServiceProxy,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }
    
    show(logId?: string): void {
    

        if (!logId) {
            this.log = new CreateOrEditLogDto();
            this.log.id = logId;


            this.active = true;
            this.modal.show();
        } else {
            this._logsServiceProxy.getLogForEdit(logId).subscribe(result => {
                this.log = result.log;



                this.active = true;
                this.modal.show();
            });
        }
        
        
    }

    save(): void {
            this.saving = true;
            
			
			
            this._logsServiceProxy.createOrEdit(this.log)
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
