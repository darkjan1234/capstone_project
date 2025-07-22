import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { PttComponent } from './ptt.component';

const routes: Routes = [
    {
        path: '',
        component: PttComponent,
        pathMatch: 'full'
    }
];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule]
})
export class PttRoutingModule { }
