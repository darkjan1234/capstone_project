import { Injectable, Inject, Optional } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { API_BASE_URL } from './service-proxies';

// DTOs
export class PttGroupListDto {
    id!: number;
    name!: string;
    description?: string;
    createdByAdminId!: number;
    createdByAdminName?: string;
    parentGroupId?: number;
    parentGroupName?: string;
    hierarchyLevel!: number;
    isActive!: boolean;
    groupType!: PttGroupType;
    memberCount!: number;
    creationTime!: Date;
}

export class CreateOrEditPttGroupDto {
    id?: number;
    name!: string;
    description?: string;
    parentGroupId?: number;
    groupType!: PttGroupType;
    isActive!: boolean;
}

export class GetPttGroupForEditOutput {
    pttGroup!: CreateOrEditPttGroupDto;
}

export class GetPttGroupsInput {
    filter?: string;
    createdByAdminId?: number;
    groupType?: PttGroupType;
    isActive?: boolean;
    sorting?: string;
    maxResultCount!: number;
    skipCount!: number;
}

export class PttGroupHierarchyDto {
    id!: number;
    name!: string;
    description?: string;
    createdByAdminId!: number;
    createdByAdminName?: string;
    parentGroupId?: number;
    hierarchyLevel!: number;
    groupType!: PttGroupType;
    isActive!: boolean;
    children!: PttGroupHierarchyDto[];
    memberCount!: number;
}

export class PttGroupMemberListDto {
    id!: number;
    pttGroupId!: number;
    pttGroupName!: string;
    userId!: number;
    userName!: string;
    userFullName!: string;
    userEmailAddress!: string;
    role!: PttGroupRole;
    isActive!: boolean;
    joinedDate!: Date;
    addedByAdminId?: number;
    addedByAdminName?: string;
}

export class GetGroupMembersInput {
    groupId!: number;
    filter?: string;
    role?: PttGroupRole;
    isActive?: boolean;
    sorting?: string;
    maxResultCount!: number;
    skipCount!: number;
}

export class AddUserToGroupInput {
    groupId!: number;
    userId!: number;
    role!: PttGroupRole;
}

export class RemoveUserFromGroupInput {
    groupId!: number;
    userId!: number;
}

export class UserListDto {
    id!: number;
    userName!: string;
    name!: string;
    surname!: string;
    emailAddress!: string;
    isActive!: boolean;
    
    get fullName(): string {
        return `${this.name} ${this.surname}`;
    }
}

export class PagedResultDto<T> {
    totalCount!: number;
    items!: T[];
}

export class ListResultDto<T> {
    items!: T[];
}

export class EntityDto {
    id!: number;
}

export enum PttGroupType {
    Admin = 1,
    User = 2,
    Mixed = 3
}

export enum PttGroupRole {
    User = 1,
    Admin = 2,
    SuperAdmin = 3
}

@Injectable()
export class PttGroupServiceProxy {
    private http: HttpClient;
    private baseUrl: string;

    constructor(@Inject(HttpClient) http: HttpClient, @Optional() @Inject(API_BASE_URL) baseUrl?: string) {
        this.http = http;
        this.baseUrl = baseUrl !== undefined && baseUrl !== null ? baseUrl : "";
    }

    getPttGroups(input: GetPttGroupsInput): Observable<PagedResultDto<PttGroupListDto>> {
        let url_ = this.baseUrl + "/api/services/app/PttGroup/GetPttGroups";
        
        const content_ = JSON.stringify(input);
        
        let options_ = {
            body: content_,
            headers: new HttpHeaders({
                "Content-Type": "application/json",
                "Accept": "application/json"
            })
        };

        return this.http.post<PagedResultDto<PttGroupListDto>>(url_, content_, {
            headers: new HttpHeaders({
                "Content-Type": "application/json",
                "Accept": "application/json"
            })
        });
    }

    getPttGroupForEdit(id: number): Observable<GetPttGroupForEditOutput> {
        let url_ = this.baseUrl + "/api/services/app/PttGroup/GetPttGroupForEdit";
        
        const content_ = JSON.stringify({ id: id });
        
        return this.http.post<GetPttGroupForEditOutput>(url_, content_, {
            headers: new HttpHeaders({
                "Content-Type": "application/json",
                "Accept": "application/json"
            })
        });
    }

    createOrEdit(input: CreateOrEditPttGroupDto): Observable<void> {
        let url_ = this.baseUrl + "/api/services/app/PttGroup/CreateOrEdit";
        
        const content_ = JSON.stringify(input);
        
        return this.http.post<void>(url_, content_, {
            headers: new HttpHeaders({
                "Content-Type": "application/json",
                "Accept": "application/json"
            })
        });
    }

    delete(id: number): Observable<void> {
        let url_ = this.baseUrl + "/api/services/app/PttGroup/Delete";
        
        const content_ = JSON.stringify({ id: id });
        
        return this.http.post<void>(url_, content_, {
            headers: new HttpHeaders({
                "Content-Type": "application/json",
                "Accept": "application/json"
            })
        });
    }

    getGroupMembers(input: GetGroupMembersInput): Observable<PagedResultDto<PttGroupMemberListDto>> {
        let url_ = this.baseUrl + "/api/services/app/PttGroup/GetGroupMembers";
        
        const content_ = JSON.stringify(input);
        
        return this.http.post<PagedResultDto<PttGroupMemberListDto>>(url_, content_, {
            headers: new HttpHeaders({
                "Content-Type": "application/json",
                "Accept": "application/json"
            })
        });
    }

    addUserToGroup(input: AddUserToGroupInput): Observable<void> {
        let url_ = this.baseUrl + "/api/services/app/PttGroup/AddUserToGroup";
        
        const content_ = JSON.stringify(input);
        
        return this.http.post<void>(url_, content_, {
            headers: new HttpHeaders({
                "Content-Type": "application/json",
                "Accept": "application/json"
            })
        });
    }

    removeUserFromGroup(input: RemoveUserFromGroupInput): Observable<void> {
        let url_ = this.baseUrl + "/api/services/app/PttGroup/RemoveUserFromGroup";
        
        const content_ = JSON.stringify(input);
        
        return this.http.post<void>(url_, content_, {
            headers: new HttpHeaders({
                "Content-Type": "application/json",
                "Accept": "application/json"
            })
        });
    }

    getGroupHierarchy(): Observable<ListResultDto<PttGroupHierarchyDto>> {
        let url_ = this.baseUrl + "/api/services/app/PttGroup/GetGroupHierarchy";
        
        return this.http.get<ListResultDto<PttGroupHierarchyDto>>(url_, {
            headers: new HttpHeaders({
                "Accept": "application/json"
            })
        });
    }

    getMyGroups(): Observable<ListResultDto<PttGroupListDto>> {
        let url_ = this.baseUrl + "/api/services/app/PttGroup/GetMyGroups";
        
        return this.http.get<ListResultDto<PttGroupListDto>>(url_, {
            headers: new HttpHeaders({
                "Accept": "application/json"
            })
        });
    }

    getAvailableUsers(): Observable<ListResultDto<UserListDto>> {
        let url_ = this.baseUrl + "/api/services/app/PttGroup/GetAvailableUsers";
        
        return this.http.get<ListResultDto<UserListDto>>(url_, {
            headers: new HttpHeaders({
                "Accept": "application/json"
            })
        });
    }
}
