using Abp.AspNetCore.Mvc.Authorization;
using Business.Solutions.Authorization;
using Business.Solutions.Storage;
using Abp.BackgroundJobs;

namespace Business.Solutions.Web.Controllers
{
    [AbpMvcAuthorize(AppPermissions.Pages_Administration_Users)]
    public class UsersController : UsersControllerBase
    {
        public UsersController(IBinaryObjectManager binaryObjectManager, IBackgroundJobManager backgroundJobManager)
            : base(binaryObjectManager, backgroundJobManager)
        {
        }
    }
}