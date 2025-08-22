import {NgModule} from '@angular/core';
import {AppSharedModule} from '@app/shared/app-shared.module';
import {AdminSharedModule} from '@app/admin/shared/admin-shared.module';
import {PPORoutingModule} from './ppo-routing.module';
import {PPOsComponent} from './ppOs.component';
import {CreateOrEditPPOModalComponent} from './create-or-edit-ppo-modal.component';
import {ViewPPOModalComponent} from './view-ppo-modal.component';



@NgModule({
    declarations: [
        PPOsComponent,
        CreateOrEditPPOModalComponent,
        ViewPPOModalComponent,
        
    ],
    imports: [AppSharedModule, PPORoutingModule , AdminSharedModule ],
    
})
export class PPOModule {
}
