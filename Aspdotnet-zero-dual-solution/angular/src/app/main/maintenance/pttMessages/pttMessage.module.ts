import {NgModule} from '@angular/core';
import {AppSharedModule} from '@app/shared/app-shared.module';
import {AdminSharedModule} from '@app/admin/shared/admin-shared.module';
import {PTTMessageRoutingModule} from './pttMessage-routing.module';
import {PTTMessagesComponent} from './pttMessages.component';
import {CreateOrEditPTTMessageModalComponent} from './create-or-edit-pttMessage-modal.component';
import {ViewPTTMessageModalComponent} from './view-pttMessage-modal.component';



@NgModule({
    declarations: [
        PTTMessagesComponent,
        CreateOrEditPTTMessageModalComponent,
        ViewPTTMessageModalComponent,
        
    ],
    imports: [AppSharedModule, PTTMessageRoutingModule , AdminSharedModule ],
    
})
export class PTTMessageModule {
}
