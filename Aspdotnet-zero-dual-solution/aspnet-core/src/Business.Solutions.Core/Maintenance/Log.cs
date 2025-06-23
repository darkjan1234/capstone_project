using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;
using Abp.Domain.Entities;
using Abp.Auditing;

namespace Business.Solutions.Maintenance
{
    [Table("Logs")]
    [Audited]
    public class Log : FullAuditedEntity<Guid>, IMayHaveTenant
    {
        public int? TenantId { get; set; }

        public virtual int UserId { get; set; }

        public virtual string Activity { get; set; }

        public virtual string LogLevel { get; set; }

    }
}