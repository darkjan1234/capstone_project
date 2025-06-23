import {NgModule} from '@angular/core';
import {AppSharedModule} from '@app/shared/app-shared.module';
import {AdminSharedModule} from '@app/admin/shared/admin-shared.module';
import {LogRoutingModule} from './log-routing.module';
import {LogsComponent} from './logs.component';
import {CreateOrEditLogModalComponent} from './create-or-edit-log-modal.component';
import {ViewLogModalComponent} from './view-log-modal.component';



@NgModule({
    declarations: [
        LogsComponent,
        CreateOrEditLogModalComponent,
        ViewLogModalComponent,
        
    ],
    imports: [AppSharedModule, LogRoutingModule , AdminSharedModule ],
    
})
export class LogModule {
}
