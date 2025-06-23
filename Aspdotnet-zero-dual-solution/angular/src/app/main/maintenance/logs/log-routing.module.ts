import {NgModule} from '@angular/core';
import {RouterModule, Routes} from '@angular/router';
import {LogsComponent} from './logs.component';



const routes: Routes = [
    {
        path: '',
        component: LogsComponent,
        pathMatch: 'full'
    },
    
    
];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule],
})
export class LogRoutingModule {
}
