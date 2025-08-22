using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;
using Abp.Domain.Entities;
using Abp.Auditing;

namespace Business.Solutions.Maintenance
{
    [Table("PPOs")]
    [Audited]
    public class PPO : FullAuditedEntity<Guid>, IMayHaveTenant
    {
        public int? TenantId { get; set; }

        [Required]
        public virtual string ProvincialName { get; set; }

        public virtual bool isActive { get; set; }

    }
}