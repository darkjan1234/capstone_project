import { Component, ViewChild, Injector, Output, EventEmitter, OnInit, ElementRef} from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { finalize } from 'rxjs/operators';
import { GroupMembersServiceProxy, CreateOrEditGroupMemberDto } from '@shared/service-proxies/service-proxies';
import { AppComponentBase } from '@shared/common/app-component-base';
import { DateTime } from 'luxon';

             import { DateTimeService } from '@app/shared/common/timing/date-time.service';



@Component({
    selector: 'createOrEditGroupMemberModal',
    templateUrl: './create-or-edit-groupMember-modal.component.html'
})
export class CreateOrEditGroupMemberModalComponent extends AppComponentBase implements OnInit{
   
    @ViewChild('createOrEditModal', { static: true }) modal: ModalDirective;

    @Output() modalSave: EventEmitter<any> = new EventEmitter<any>();

    active = false;
    saving = false;

    groupMember: CreateOrEditGroupMemberDto = new CreateOrEditGroupMemberDto();




    constructor(
        injector: Injector,
        private _groupMembersServiceProxy: GroupMembersServiceProxy,
             private _dateTimeService: DateTimeService
    ) {
        super(injector);
    }
    
    show(groupMemberId?: string): void {
    

        if (!groupMemberId) {
            this.groupMember = new CreateOrEditGroupMemberDto();
            this.groupMember.id = groupMemberId;


            this.active = true;
            this.modal.show();
        } else {
            this._groupMembersServiceProxy.getGroupMemberForEdit(groupMemberId).subscribe(result => {
                this.groupMember = result.groupMember;



                this.active = true;
                this.modal.show();
            });
        }
        
        
    }

    save(): void {
            this.saving = true;
            
			
			
            this._groupMembersServiceProxy.createOrEdit(this.groupMember)
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
