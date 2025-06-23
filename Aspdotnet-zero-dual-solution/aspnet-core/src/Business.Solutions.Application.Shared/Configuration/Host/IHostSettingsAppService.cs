using System.Threading.Tasks;
using Abp.Application.Services;
using Business.Solutions.Configuration.Host.Dto;

namespace Business.Solutions.Configuration.Host
{
    public interface IHostSettingsAppService : IApplicationService
    {
        Task<HostSettingsEditDto> GetAllSettings();

        Task UpdateAllSettings(HostSettingsEditDto input);

        Task SendTestEmail(SendTestEmailInput input);
    }
}
