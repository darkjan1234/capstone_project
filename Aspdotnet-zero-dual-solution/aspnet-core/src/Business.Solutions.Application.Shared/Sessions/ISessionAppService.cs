using System.Threading.Tasks;
using Abp.Application.Services;
using Business.Solutions.Sessions.Dto;

namespace Business.Solutions.Sessions
{
    public interface ISessionAppService : IApplicationService
    {
        Task<GetCurrentLoginInformationsOutput> GetCurrentLoginInformations();

        Task<UpdateUserSignInTokenOutput> UpdateUserSignInToken();
    }
}
