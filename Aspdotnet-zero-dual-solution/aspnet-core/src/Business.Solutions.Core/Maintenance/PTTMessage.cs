using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;
using Abp.Domain.Entities;

namespace Business.Solutions.Maintenance
{
    [Table("PTTMessages")]
    public class PTTMessage : FullAuditedEntity<Guid>, IMayHaveTenant
    {
        public int? TenantId { get; set; }

        public virtual int SenderId { get; set; }

        public virtual int ReceiverId { get; set; }

        public virtual int GroupId { get; set; }

        public virtual string AudioPath { get; set; }

        public virtual int DurationSeconds { get; set; }

    }
}