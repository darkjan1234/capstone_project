import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { ModalModule } from 'ngx-bootstrap/modal';
import { TabsModule } from 'ngx-bootstrap/tabs';
import { TooltipModule } from 'ngx-bootstrap/tooltip';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { PopoverModule } from 'ngx-bootstrap/popover';

import { AppSharedModule } from '@app/shared/app-shared.module';
import { AdminSharedModule } from '@app/admin/shared/admin-shared.module';
import { PttGroupsRoutingModule } from './ptt-groups-routing.module';

import { PttGroupsComponent } from './ptt-groups.component';
import { CreateOrEditPttGroupModalComponent } from './create-or-edit-ptt-group-modal.component';
import { GroupMembersModalComponent } from './group-members-modal.component';
import { PttGroupServiceProxy } from '@shared/service-proxies/ptt-group-service-proxy';

@NgModule({
    declarations: [
        PttGroupsComponent,
        CreateOrEditPttGroupModalComponent,
        GroupMembersModalComponent
    ],
    imports: [
        CommonModule,
        FormsModule,
        ReactiveFormsModule,
        ModalModule,
        TabsModule,
        TooltipModule,
        BsDropdownModule,
        PopoverModule,
        AppSharedModule,
        AdminSharedModule,
        PttGroupsRoutingModule
    ],
    providers: [
        PttGroupServiceProxy
    ]
})
export class PttGroupsModule { }
