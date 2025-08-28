import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { PttGroupsComponent } from './ptt-groups.component';

const routes: Routes = [
    {
        path: '',
        component: PttGroupsComponent,
        pathMatch: 'full'
    }
];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule],
})
export class PttGroupsRoutingModule { }
