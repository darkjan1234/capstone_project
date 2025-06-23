import {NgModule} from '@angular/core';
import {AppSharedModule} from '@app/shared/app-shared.module';
import {AdminSharedModule} from '@app/admin/shared/admin-shared.module';
import {PttUserRoutingModule} from './pttUser-routing.module';
import {PttUsersComponent} from './pttUsers.component';
import {CreateOrEditPttUserModalComponent} from './create-or-edit-pttUser-modal.component';
import {ViewPttUserModalComponent} from './view-pttUser-modal.component';



@NgModule({
    declarations: [
        PttUsersComponent,
        CreateOrEditPttUserModalComponent,
        ViewPttUserModalComponent,
        
    ],
    imports: [AppSharedModule, PttUserRoutingModule , AdminSharedModule ],
    
})
export class PttUserModule {
}
