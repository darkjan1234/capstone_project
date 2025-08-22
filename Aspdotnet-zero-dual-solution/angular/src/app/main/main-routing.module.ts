import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';

@NgModule({
    imports: [
        RouterModule.forChild([
            {
                path: '',
                children: [
                    
                    {
                        path: 'maintenance/ppOs',
                        loadChildren: () => import('./maintenance/ppOs/ppo.module').then(m => m.PPOModule),
                        data: { permission: 'Pages.PPOs' }
                    },
                
                    {
                        path: 'maintenance/logs',
                        loadChildren: () => import('./maintenance/logs/log.module').then((m) => m.LogModule),
                        data: { permission: 'Pages.Logs' },
                    },

                    {
                        path: 'maintenance/notifications',
                        loadChildren: () =>
                            import('./maintenance/notifications/notification.module').then((m) => m.NotificationModule),
                        data: { permission: 'Pages.Notifications' },
                    },

                    {
                        path: 'maintenance/communicationHistories',
                        loadChildren: () =>
                            import('./maintenance/communicationHistories/communicationHistory.module').then(
                                (m) => m.CommunicationHistoryModule,
                            ),
                        data: { permission: 'Pages.CommunicationHistories' },
                    },

                    {
                        path: 'maintenance/pttMessages',
                        loadChildren: () =>
                            import('./maintenance/pttMessages/pttMessage.module').then((m) => m.PTTMessageModule),
                        data: { permission: 'Pages.PTTMessages' },
                    },

                    {
                        path: 'maintenance/groupMembers',
                        loadChildren: () =>
                            import('./maintenance/groupMembers/groupMember.module').then((m) => m.GroupMemberModule),
                        data: { permission: 'Pages.GroupMembers' },
                    },

                    {
                        path: 'maintenance/groups',
                        loadChildren: () => import('./maintenance/groups/group.module').then((m) => m.GroupModule),
                        data: { permission: 'Pages.Groups' },
                    },

                    {
                        path: 'maintenance/pttUsers',
                        loadChildren: () =>
                            import('./maintenance/pttUsers/pttUser.module').then((m) => m.PttUserModule),
                        data: { permission: 'Pages.PttUsers' },
                    },

                    {
                        path: 'ptt',
                        loadChildren: () => import('./ptt/ptt.module').then((m) => m.PttModule),
                        data: { permission: 'Pages.Administration' },
                    },

                    {
                        path: 'dashboard',
                        loadChildren: () => import('./dashboard/dashboard.module').then((m) => m.DashboardModule),
                        data: { permission: 'Pages.Tenant.Dashboard' },
                    },
                    { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
                    { path: '**', redirectTo: 'dashboard' },
                ],
            },
        ]),
    ],
    exports: [RouterModule],
})
export class MainRoutingModule {}
