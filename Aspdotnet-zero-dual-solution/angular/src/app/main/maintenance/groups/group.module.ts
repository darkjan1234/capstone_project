import {NgModule} from '@angular/core';
import {AppSharedModule} from '@app/shared/app-shared.module';
import {AdminSharedModule} from '@app/admin/shared/admin-shared.module';
import {GroupRoutingModule} from './group-routing.module';
import {GroupsComponent} from './groups.component';
import {CreateOrEditGroupModalComponent} from './create-or-edit-group-modal.component';
import {ViewGroupModalComponent} from './view-group-modal.component';



@NgModule({
    declarations: [
        GroupsComponent,
        CreateOrEditGroupModalComponent,
        ViewGroupModalComponent,
        
    ],
    imports: [AppSharedModule, GroupRoutingModule , AdminSharedModule ],
    
})
export class GroupModule {
}
