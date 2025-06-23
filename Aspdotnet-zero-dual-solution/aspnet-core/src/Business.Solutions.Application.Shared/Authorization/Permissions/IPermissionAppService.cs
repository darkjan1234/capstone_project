using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.Authorization.Permissions.Dto;

namespace Business.Solutions.Authorization.Permissions
{
    public interface IPermissionAppService : IApplicationService
    {
        ListResultDto<FlatPermissionWithLevelDto> GetAllPermissions();
    }
}
