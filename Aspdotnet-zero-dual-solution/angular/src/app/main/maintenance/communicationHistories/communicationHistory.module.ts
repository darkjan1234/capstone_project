import {NgModule} from '@angular/core';
import {AppSharedModule} from '@app/shared/app-shared.module';
import {AdminSharedModule} from '@app/admin/shared/admin-shared.module';
import {CommunicationHistoryRoutingModule} from './communicationHistory-routing.module';
import {CommunicationHistoriesComponent} from './communicationHistories.component';
import {CreateOrEditCommunicationHistoryModalComponent} from './create-or-edit-communicationHistory-modal.component';
import {ViewCommunicationHistoryModalComponent} from './view-communicationHistory-modal.component';



@NgModule({
    declarations: [
        CommunicationHistoriesComponent,
        CreateOrEditCommunicationHistoryModalComponent,
        ViewCommunicationHistoryModalComponent,
        
    ],
    imports: [AppSharedModule, CommunicationHistoryRoutingModule , AdminSharedModule ],
    
})
export class CommunicationHistoryModule {
}
