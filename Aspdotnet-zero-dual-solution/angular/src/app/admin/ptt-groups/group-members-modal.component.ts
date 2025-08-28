import { Component, ViewChild, Injector, OnInit } from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { finalize } from 'rxjs/operators';
import { AppComponentBase } from '@shared/common/app-component-base';
import { PagedListingComponentBase, PagedRequestDto } from '@shared/common/paged-listing-component-base';
import {
    PttGroupServiceProxy,
    PttGroupMemberListDto,
    GetGroupMembersInput,
    AddUserToGroupInput,
    RemoveUserFromGroupInput,
    UserListDto,
    PttGroupRole
} from '@shared/service-proxies/service-proxies';

class PagedGroupMembersRequestDto extends PagedRequestDto {
    groupId: number;
    keyword: string;
    role: PttGroupRole | undefined;
    isActive: boolean | undefined;
}

@Component({
    selector: 'groupMembersModal',
    templateUrl: './group-members-modal.component.html',
    styleUrls: ['./group-members-modal.component.less']
})
export class GroupMembersModalComponent extends AppComponentBase implements OnInit {

    @ViewChild('groupMembersModal', { static: true }) modal: ModalDirective;

    active = false;
    groupId: number;
    groupName: string;
    
    groupMembers: any = { items: [], totalCount: 0 };
    availableUsers: UserListDto[] = [];
    
    memberFilterText = '';
    selectedMemberRole: string = '';
    selectedMemberStatus: string = '';
    
    selectedUserId: number;
    selectedRole: PttGroupRole;
    addingUser = false;
    
    memberRequest: PagedGroupMembersRequestDto = new PagedGroupMembersRequestDto();
    
    // Enum references for template
    pttGroupRole = PttGroupRole;

    constructor(
        injector: Injector,
        private _pttGroupService: PttGroupServiceProxy
    ) {
        super(injector);
        this.memberRequest.maxResultCount = 10;
    }

    ngOnInit(): void {
        this.loadAvailableUsers();
    }

    show(groupId: number, groupName: string): void {
        this.groupId = groupId;
        this.groupName = groupName;
        this.active = true;
        
        this.resetFilters();
        this.getGroupMembers();
        this.modal.show();
    }

    close(): void {
        this.active = false;
        this.modal.hide();
    }

    getGroupMembers(event?: any): void {
        if (!this.active) return;

        this.memberRequest.groupId = this.groupId;
        this.memberRequest.keyword = this.memberFilterText;
        this.memberRequest.role = this.selectedMemberRole ? parseInt(this.selectedMemberRole) : undefined;
        this.memberRequest.isActive = this.selectedMemberStatus ? this.selectedMemberStatus === 'true' : undefined;
        
        if (event) {
            this.memberRequest.skipCount = (event - 1) * this.memberRequest.maxResultCount;
        } else {
            this.memberRequest.skipCount = 0;
        }

        this._pttGroupService
            .getGroupMembers(this.memberRequest)
            .subscribe((result) => {
                this.groupMembers = result;
            });
    }

    addUserToGroup(): void {
        if (!this.selectedUserId || !this.selectedRole) {
            return;
        }

        this.addingUser = true;

        const input = new AddUserToGroupInput();
        input.groupId = this.groupId;
        input.userId = this.selectedUserId;
        input.role = this.selectedRole;

        this._pttGroupService
            .addUserToGroup(input)
            .pipe(
                finalize(() => {
                    this.addingUser = false;
                })
            )
            .subscribe(() => {
                this.notify.success(this.l('UserAddedToGroupSuccessfully'));
                this.selectedUserId = null;
                this.selectedRole = null;
                this.getGroupMembers();
                this.loadAvailableUsers(); // Refresh available users
            });
    }

    removeUserFromGroup(member: PttGroupMemberListDto): void {
        abp.message.confirm(
            this.l('RemoveUserFromGroupWarningMessage', member.userFullName),
            undefined,
            (result: boolean) => {
                if (result) {
                    const input = new RemoveUserFromGroupInput();
                    input.groupId = this.groupId;
                    input.userId = member.userId;

                    this._pttGroupService.removeUserFromGroup(input).subscribe(() => {
                        this.notify.success(this.l('UserRemovedFromGroupSuccessfully'));
                        this.getGroupMembers();
                        this.loadAvailableUsers(); // Refresh available users
                    });
                }
            }
        );
    }

    editMemberRole(member: PttGroupMemberListDto): void {
        // Show role edit dialog
        abp.message.prompt(
            this.l('EditMemberRole'),
            this.l('SelectNewRole'),
            (result) => {
                if (result) {
                    // Update member role logic here
                    this.notify.info(this.l('FeatureComingSoon'));
                }
            }
        );
    }

    deactivateMember(member: PttGroupMemberListDto): void {
        abp.message.confirm(
            this.l('DeactivateMemberWarningMessage', member.userFullName),
            undefined,
            (result: boolean) => {
                if (result) {
                    // Deactivate member logic here
                    this.notify.info(this.l('FeatureComingSoon'));
                }
            }
        );
    }

    activateMember(member: PttGroupMemberListDto): void {
        // Activate member logic here
        this.notify.info(this.l('FeatureComingSoon'));
    }

    loadAvailableUsers(): void {
        this._pttGroupService.getAvailableUsers().subscribe((result) => {
            // Filter out users who are already members of this group
            if (this.groupMembers.items && this.groupMembers.items.length > 0) {
                const memberUserIds = this.groupMembers.items.map(m => m.userId);
                this.availableUsers = result.items.filter(u => !memberUserIds.includes(u.id));
            } else {
                this.availableUsers = result.items;
            }
        });
    }

    resetFilters(): void {
        this.memberFilterText = '';
        this.selectedMemberRole = '';
        this.selectedMemberStatus = '';
        this.selectedUserId = null;
        this.selectedRole = null;
    }

    getUserInitials(fullName: string): string {
        if (!fullName) return 'U';
        
        const names = fullName.split(' ');
        if (names.length >= 2) {
            return (names[0].charAt(0) + names[1].charAt(0)).toUpperCase();
        }
        return fullName.charAt(0).toUpperCase();
    }

    getRoleBadgeClass(role: PttGroupRole): string {
        switch (role) {
            case PttGroupRole.SuperAdmin:
                return 'badge-light-danger';
            case PttGroupRole.Admin:
                return 'badge-light-warning';
            case PttGroupRole.User:
                return 'badge-light-primary';
            default:
                return 'badge-light-secondary';
        }
    }

    getRoleText(role: PttGroupRole): string {
        switch (role) {
            case PttGroupRole.SuperAdmin:
                return this.l('SuperAdmin');
            case PttGroupRole.Admin:
                return this.l('Admin');
            case PttGroupRole.User:
                return this.l('User');
            default:
                return '';
        }
    }
}
