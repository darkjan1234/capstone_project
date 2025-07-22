import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AppSharedModule } from '@app/shared/app-shared.module';
import { PttRoutingModule } from './ptt-routing.module';
import { PttComponent } from './ptt.component';

@NgModule({
    declarations: [PttComponent],
    imports: [CommonModule, FormsModule, AppSharedModule, PttRoutingModule],
})
export class PttModule {}
