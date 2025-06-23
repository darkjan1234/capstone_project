using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;
using Abp.Domain.Entities;

namespace Business.Solutions.Maintenance
{
    [Table("PttUsers")]
    public class PttUser : FullAuditedEntity<Guid>, IMayHaveTenant
    {
        public int? TenantId { get; set; }

        [Required]
        public virtual string FullName { get; set; }

        [Required]
        public virtual string Email { get; set; }

        [Required]
        public virtual string PasswordHash { get; set; }

        [Required]
        public virtual string Role { get; set; }

        public virtual bool Status { get; set; }

    }
}