using System.Threading.Tasks;
using Abp.Application.Services;
using Business.Solutions.Editions.Dto;
using Business.Solutions.MultiTenancy.Dto;

namespace Business.Solutions.MultiTenancy
{
    public interface ITenantRegistrationAppService: IApplicationService
    {
        Task<RegisterTenantOutput> RegisterTenant(RegisterTenantInput input);

        Task<EditionsSelectOutput> GetEditionsForSelect();

        Task<EditionSelectDto> GetEdition(int editionId);
    }
}