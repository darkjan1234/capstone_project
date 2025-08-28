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
        /// PPO Region Code (e.g., "REGION1", "REGION2", "BOHOL", "CEBU")
        /// Used for communication isolation between regions
        /// </summary>
        [StringLength(50)]
        public string RegionCode { get; set; }

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
        /// Group type: PPO_Region, Field_Team, Special_Unit
        /// </summary>
        public PttGroupType GroupType { get; set; }

        /// <summary>
        /// Security: Check if this group can communicate with another group
        /// Only groups in the same region can communicate (except Super Admin)
        /// </summary>
        public bool CanCommunicateWith(PttGroup otherGroup)
        {
            // Super Admin (no region code) can communicate with everyone
            if (string.IsNullOrEmpty(this.RegionCode) || string.IsNullOrEmpty(otherGroup.RegionCode))
                return true;

            // Same region groups can communicate
            return this.RegionCode.Equals(otherGroup.RegionCode, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Check if a user can access this group based on their region
        /// </summary>
        public bool CanUserAccess(User user)
        {
            // Super Admin can access all groups (check by PttRole when available)
            if (user.UserName == "admin")
                return true;

            // Users can only access groups in their region
            // This will work properly after database migration adds RegionCode
            return true; // Placeholder for now - will be implemented after DB update
        }

        public PttGroup()
        {
            ChildGroups = new HashSet<PttGroup>();
            Members = new HashSet<PttGroupMember>();
            IsActive = true;
        }

        public PttGroup(string name, long createdByAdminId, PttGroupType groupType = PttGroupType.Field_Team)
            : this()
        {
            Name = name;
            CreatedByAdminId = createdByAdminId;
            GroupType = groupType;
        }
    }

    public enum PttGroupType
    {
        PPO_Region = 1,      // PPO Regional Office (like Region1, Region2)
        Field_Team = 2,      // Field teams under a PPO
        Special_Unit = 3     // Special operations units
    }
}
