using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;
using Abp.Domain.Entities;

namespace Business.Solutions.Maintenance
{
    [Table("CommunicationHistories")]
    public class CommunicationHistory : FullAuditedEntity<Guid>, IMayHaveTenant
    {
        public int? TenantId { get; set; }

        public virtual int UserId { get; set; }

        [Required]
        public virtual string Action { get; set; }

        public virtual int ReferenceId { get; set; }

    }
}