using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;
using Abp.Domain.Entities;

namespace Business.Solutions.Maintenance
{
    [Table("Notifications")]
    public class Notification : FullAuditedEntity<Guid>, IMayHaveTenant
    {
        public int? TenantId { get; set; }

        public virtual int UserId { get; set; }

        public virtual string Message { get; set; }

        public virtual bool Isread { get; set; }

    }
}