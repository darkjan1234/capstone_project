import { Component, ViewChild, Injector, Output, EventEmitter, OnInit, ElementRef} from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { finalize } from 'rxjs/operators';
import { PttUsersServiceProxy, CreateOrEditPttUserDto } from '@shared/service-proxies/service-proxies';
import { AppComponentBase } from '@shared/common/app-component-base';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';



@Component({
    selector: 'createOrEditPttUserModal',
    templateUrl: './create-or-edit-pttUser-modal.component.html'
})
export class CreateOrEditPttUserModalComponent extends AppComponentBase implements OnInit{
   
    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;

    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;

    pttUser: CreateOrEditPttUserDto = new CreateOrEditPttUserDto();




    constructor(
        injector: Injector,
        private _pttUsersServiceProxy: PttUsersServiceProxy,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }
    
    show(pttUserId?: string): void {
    

        if (!pttUserId) {
            this.pttUser = new CreateOrEditPttUserDto();
            this.pttUser.id = pttUserId;


            this.active = true;
            this.modal.show();
        } else {
            this._pttUsersServiceProxy.getPttUserForEdit(pttUserId).subscribe(result => {
                this.pttUser = result.pttUser;



                this.active = true;
                this.modal.show();
            });
        }
        
        
    }

    save(): void {
            this.saving = true;
            
			
			
            this._pttUsersServiceProxy.createOrEdit(this.pttUser)
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
