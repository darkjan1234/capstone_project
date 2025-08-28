using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;
using Business.Solutions.Authorization.Users;

namespace Business.Solutions.PTT
{
    [Table("PttGroupMembers")]
    public class PttGroupMember : FullAuditedEntity<long>
    {
        /// <summary>
        /// PTT Group ID
        /// </summary>
        public long PttGroupId { get; set; }

        [ForeignKey("PttGroupId")]
        public virtual PttGroup PttGroup { get; set; }

        /// <summary>
        /// User ID
        /// </summary>
        public long UserId { get; set; }

        [ForeignKey("UserId")]
        public virtual User User { get; set; }

        /// <summary>
        /// Role in this group (Admin, User)
        /// </summary>
        public PttGroupRole Role { get; set; }

        /// <summary>
        /// Is this member active in the group
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// When the user joined this group
        /// </summary>
        public DateTime JoinedDate { get; set; }

        /// <summary>
        /// Admin who added this user to the group
        /// </summary>
        public long? AddedByAdminId { get; set; }

        [ForeignKey("AddedByAdminId")]
        public virtual User AddedByAdmin { get; set; }

        public PttGroupMember()
        {
            IsActive = true;
            JoinedDate = DateTime.UtcNow;
        }

        public PttGroupMember(long pttGroupId, long userId, PttGroupRole role, long? addedByAdminId = null)
            : this()
        {
            PttGroupId = pttGroupId;
            UserId = userId;
            Role = role;
            AddedByAdminId = addedByAdminId;
        }
    }

    public enum PttGroupRole
    {
        User = 1,
        Admin = 2,
        SuperAdmin = 3
    }
}
