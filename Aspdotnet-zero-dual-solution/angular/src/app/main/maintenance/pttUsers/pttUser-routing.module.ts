import {NgModule} from '@angular/core';
import {RouterModule, Routes} from '@angular/router';
import {PttUsersComponent} from './pttUsers.component';



const routes: Routes = [
    {
        path: '',
        component: PttUsersComponent,
        pathMatch: 'full'
    },
    
    
];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule],
})
export class PttUserRoutingModule {
}
