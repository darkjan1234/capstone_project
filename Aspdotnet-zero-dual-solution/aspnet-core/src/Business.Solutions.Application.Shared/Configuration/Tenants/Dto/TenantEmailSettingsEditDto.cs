using Abp.Auditing;
using Business.Solutions.Configuration.Dto;

namespace Business.Solutions.Configuration.Tenants.Dto
{
    public class TenantEmailSettingsEditDto : EmailSettingsEditDto
    {
        public bool UseHostDefaultEmailSettings { get; set; }
    }
}