import { Component, ViewChild, Injector, Output, EventEmitter, OnInit, ElementRef} from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { finalize } from 'rxjs/operators';
import { GroupsServiceProxy, CreateOrEditGroupDto } from '@shared/service-proxies/service-proxies';
import { AppComponentBase } from '@shared/common/app-component-base';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';



@Component({
    selector: 'createOrEditGroupModal',
    templateUrl: './create-or-edit-group-modal.component.html'
})
export class CreateOrEditGroupModalComponent extends AppComponentBase implements OnInit{
   
    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;

    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;

    group: CreateOrEditGroupDto = new CreateOrEditGroupDto();




    constructor(
        injector: Injector,
        private _groupsServiceProxy: GroupsServiceProxy,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }
    
    show(groupId?: string): void {
    

        if (!groupId) {
            this.group = new CreateOrEditGroupDto();
            this.group.id = groupId;


            this.active = true;
            this.modal.show();
        } else {
            this._groupsServiceProxy.getGroupForEdit(groupId).subscribe(result => {
                this.group = result.group;



                this.active = true;
                this.modal.show();
            });
        }
        
        
    }

    save(): void {
            this.saving = true;
            
			
			
            this._groupsServiceProxy.createOrEdit(this.group)
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
