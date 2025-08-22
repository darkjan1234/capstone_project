import { Component, ViewChild, Injector, Output, EventEmitter, OnInit, ElementRef} from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { finalize } from 'rxjs/operators';
import { PPOsServiceProxy, CreateOrEditPPODto } from '@shared/service-proxies/service-proxies';
import { AppComponentBase } from '@shared/common/app-component-base';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';



@Component({
    selector: 'createOrEditPPOModal',
    templateUrl: './create-or-edit-ppo-modal.component.html'
})
export class CreateOrEditPPOModalComponent extends AppComponentBase implements OnInit{
   
    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;

    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;

    ppo: CreateOrEditPPODto = new CreateOrEditPPODto();




    constructor(
        injector: Injector,
        private _ppOsServiceProxy: PPOsServiceProxy,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }
    
    show(ppoId?: string): void {
    

        if (!ppoId) {
            this.ppo = new CreateOrEditPPODto();
            this.ppo.id = ppoId;


            this.active = true;
            this.modal.show();
        } else {
            this._ppOsServiceProxy.getPPOForEdit(ppoId).subscribe(result => {
                this.ppo = result.ppo;



                this.active = true;
                this.modal.show();
            });
        }
        
        
    }

    save(): void {
            this.saving = true;
            
			
			
            this._ppOsServiceProxy.createOrEdit(this.ppo)
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
