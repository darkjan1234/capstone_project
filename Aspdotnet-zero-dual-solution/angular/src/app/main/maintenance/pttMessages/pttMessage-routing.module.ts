import {NgModule} from '@angular/core';
import {RouterModule, Routes} from '@angular/router';
import {PTTMessagesComponent} from './pttMessages.component';



const routes: Routes = [
    {
        path: '',
        component: PTTMessagesComponent,
        pathMatch: 'full'
    },
    
    
];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule],
})
export class PTTMessageRoutingModule {
}
