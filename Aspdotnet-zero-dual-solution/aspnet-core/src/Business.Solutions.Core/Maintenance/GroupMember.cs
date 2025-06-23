using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;
using Abp.Domain.Entities;
using Abp.Auditing;

namespace Business.Solutions.Maintenance
{
    [Table("GroupMembers")]
    [Audited]
    public class GroupMember : FullAuditedEntity<Guid>, IMayHaveTenant
    {
        public int? TenantId { get; set; }

        public virtual int GroupId { get; set; }

        public virtual string PttUserId { get; set; }

        [Required]
        public virtual string RoleInGroup { get; set; }

    }
}