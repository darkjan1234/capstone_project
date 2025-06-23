using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.Authorization.Users.Dto;

namespace Business.Solutions.Authorization.Users
{
    public interface IUserLoginAppService : IApplicationService
    {
        Task<PagedResultDto<UserLoginAttemptDto>> GetUserLoginAttempts(GetLoginAttemptsInput input);
    }
}
