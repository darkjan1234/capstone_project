using System.Threading.Tasks;
using Abp.Application.Services;
using Business.Solutions.Install.Dto;

namespace Business.Solutions.Install
{
    public interface IInstallAppService : IApplicationService
    {
        Task Setup(InstallDto input);

        AppSettingsJsonDto GetAppSettingsJson();

        CheckDatabaseOutput CheckDatabase();
    }
}