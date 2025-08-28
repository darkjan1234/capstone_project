using System;
using System.Collections.Generic;
using Abp.Application.Services.Dto;
using Abp.AutoMapper;
using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.PTT.Dto
{
    [AutoMapFrom(typeof(PttGroup))]
    public class PttGroupListDto : EntityDto<long>
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public long CreatedByAdminId { get; set; }
        public string CreatedByAdminName { get; set; }
        public long? ParentGroupId { get; set; }
        public string ParentGroupName { get; set; }
        public int HierarchyLevel { get; set; }
        public bool IsActive { get; set; }
        public PttGroupType GroupType { get; set; }
        public int MemberCount { get; set; }
        public DateTime CreationTime { get; set; }
    }

    [AutoMapTo(typeof(PttGroup))]
    public class CreateOrEditPttGroupDto : EntityDto<long?>
    {
        [Required]
        [StringLength(PttGroup.MaxNameLength)]
        public string Name { get; set; }

        [StringLength(PttGroup.MaxDescriptionLength)]
        public string Description { get; set; }

        public long? ParentGroupId { get; set; }

        [Required]
        public PttGroupType GroupType { get; set; }

        public bool IsActive { get; set; } = true;
    }

    public class GetPttGroupForEditOutput
    {
        public CreateOrEditPttGroupDto PttGroup { get; set; }
    }

    public class GetPttGroupsInput : PagedAndSortedResultRequestDto
    {
        public string Filter { get; set; }
        public long? CreatedByAdminId { get; set; }
        public PttGroupType? GroupType { get; set; }
        public bool? IsActive { get; set; }
    }

    public class PttGroupHierarchyDto : EntityDto<long>
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public long CreatedByAdminId { get; set; }
        public string CreatedByAdminName { get; set; }
        public long? ParentGroupId { get; set; }
        public int HierarchyLevel { get; set; }
        public PttGroupType GroupType { get; set; }
        public bool IsActive { get; set; }
        public List<PttGroupHierarchyDto> Children { get; set; }
        public int MemberCount { get; set; }

        public PttGroupHierarchyDto()
        {
            Children = new List<PttGroupHierarchyDto>();
        }
    }

    [AutoMapFrom(typeof(PttGroupMember))]
    public class PttGroupMemberListDto : EntityDto<long>
    {
        public long PttGroupId { get; set; }
        public string PttGroupName { get; set; }
        public long UserId { get; set; }
        public string UserName { get; set; }
        public string UserFullName { get; set; }
        public string UserEmailAddress { get; set; }
        public PttGroupRole Role { get; set; }
        public bool IsActive { get; set; }
        public DateTime JoinedDate { get; set; }
        public long? AddedByAdminId { get; set; }
        public string AddedByAdminName { get; set; }
    }

    public class GetGroupMembersInput : PagedAndSortedResultRequestDto
    {
        public long GroupId { get; set; }
        public string Filter { get; set; }
        public PttGroupRole? Role { get; set; }
        public bool? IsActive { get; set; }
    }

    public class AddUserToGroupInput
    {
        public long GroupId { get; set; }
        public long UserId { get; set; }
        public PttGroupRole Role { get; set; }
    }

    public class RemoveUserFromGroupInput
    {
        public long GroupId { get; set; }
        public long UserId { get; set; }
    }

    public class UserListDto : EntityDto<long>
    {
        public string UserName { get; set; }
        public string Name { get; set; }
        public string Surname { get; set; }
        public string EmailAddress { get; set; }
        public bool IsActive { get; set; }
        public string FullName => $"{Name} {Surname}";
    }
}
