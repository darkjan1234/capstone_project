import {NgModule} from '@angular/core';
import {AppSharedModule} from '@app/shared/app-shared.module';
import {AdminSharedModule} from '@app/admin/shared/admin-shared.module';
import {GroupMemberRoutingModule} from './groupMember-routing.module';
import {GroupMembersComponent} from './groupMembers.component';
import {CreateOrEditGroupMemberModalComponent} from './create-or-edit-groupMember-modal.component';
import {ViewGroupMemberModalComponent} from './view-groupMember-modal.component';



@NgModule({
    declarations: [
        GroupMembersComponent,
        CreateOrEditGroupMemberModalComponent,
        ViewGroupMemberModalComponent,
        
    ],
    imports: [AppSharedModule, GroupMemberRoutingModule , AdminSharedModule ],
    
})
export class GroupMemberModule {
}
