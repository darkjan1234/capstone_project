import {NgModule} from '@angular/core';
import {AppSharedModule} from '@app/shared/app-shared.module';
import {AdminSharedModule} from '@app/admin/shared/admin-shared.module';
import {NotificationRoutingModule} from './notification-routing.module';
import {NotificationsComponent} from './notifications.component';
import {CreateOrEditNotificationModalComponent} from './create-or-edit-notification-modal.component';
import {ViewNotificationModalComponent} from './view-notification-modal.component';



@NgModule({
    declarations: [
        NotificationsComponent,
        CreateOrEditNotificationModalComponent,
        ViewNotificationModalComponent,
        
    ],
    imports: [AppSharedModule, NotificationRoutingModule , AdminSharedModule ],
    
})
export class NotificationModule {
}
