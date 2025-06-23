using Abp.Application.Services;
using Business.Solutions.Dto;
using Business.Solutions.Logging.Dto;

namespace Business.Solutions.Logging
{
    public interface IWebLogAppService : IApplicationService
    {
        GetLatestWebLogsOutput GetLatestWebLogs();

        FileDto DownloadWebLogs();
    }
}
