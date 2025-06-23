import {NgModule} from '@angular/core';
import {RouterModule, Routes} from '@angular/router';
import {GroupMembersComponent} from './groupMembers.component';



const routes: Routes = [
    {
        path: '',
        component: GroupMembersComponent,
        pathMatch: 'full'
    },
    
    
];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule],
})
export class GroupMemberRoutingModule {
}
