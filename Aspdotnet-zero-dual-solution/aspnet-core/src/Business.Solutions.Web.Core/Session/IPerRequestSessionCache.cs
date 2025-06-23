using System.Threading.Tasks;
using Business.Solutions.Sessions.Dto;

namespace Business.Solutions.Web.Session
{
    public interface IPerRequestSessionCache
    {
        Task<GetCurrentLoginInformationsOutput> GetCurrentLoginInformationsAsync();
    }
}
