import {NgModule} from '@angular/core';
import {RouterModule, Routes} from '@angular/router';
import {PPOsComponent} from './ppOs.component';



const routes: Routes = [
    {
        path: '',
        component: PPOsComponent,
        pathMatch: 'full'
    },
    
    
];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule],
})
export class PPORoutingModule {
}
