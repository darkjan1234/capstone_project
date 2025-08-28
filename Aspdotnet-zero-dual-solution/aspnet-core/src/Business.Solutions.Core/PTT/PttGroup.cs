using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;
using Business.Solutions.Authorization.Users;

namespace Business.Solutions.PTT
{
    [Table("PttGroups")]
    public class PttGroup : FullAuditedEntity<long>
    {
        public const int MaxNameLength = 128;
        public const int MaxDescriptionLength = 500;

        [Required]
        [StringLength(MaxNameLength)]
        public string Name { get; set; }

        [StringLength(MaxDescriptionLength)]
        public string Description { get; set; }

        /// <summary>
        /// The admin user who created this group
        /// </summary>
        public long CreatedByAdminId { get; set; }

        [ForeignKey("CreatedByAdminId")]
        public virtual User CreatedByAdmin { get; set; }

        /// <summary>
        /// Parent group ID for hierarchy
        /// </summary>
        public long? ParentGroupId { get; set; }

        [ForeignKey("ParentGroupId")]
        public virtual PttGroup ParentGroup { get; set; }

        /// <summary>
        /// Child groups
        /// </summary>
        public virtual ICollection<PttGroup> ChildGroups { get; set; }

        /// <summary>
        /// Users in this group
        /// </summary>
        public virtual ICollection<PttGroupMember> Members { get; set; }

        /// <summary>
        /// Group hierarchy level (0 = root admin, 1 = sub-admin, etc.)
        /// </summary>
        public int HierarchyLevel { get; set; }

        /// <summary>
        /// Is this group active
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Group type: Admin, User, Mixed
        /// </summary>
        public PttGroupType GroupType { get; set; }

        public PttGroup()
        {
            ChildGroups = new HashSet<PttGroup>();
            Members = new HashSet<PttGroupMember>();
            IsActive = true;
        }

        public PttGroup(string name, long createdByAdminId, PttGroupType groupType = PttGroupType.User)
            : this()
        {
            Name = name;
            CreatedByAdminId = createdByAdminId;
            GroupType = groupType;
        }
    }

    public enum PttGroupType
    {
        Admin = 1,
        User = 2,
        Mixed = 3
    }
}
