using Abp.AspNetCore.Mvc.Authorization;
using Business.Solutions.Authorization.Users.Profile;
using Business.Solutions.Graphics;
using Business.Solutions.Storage;

namespace Business.Solutions.Web.Controllers
{
    [AbpMvcAuthorize]
    public class ProfileController : ProfileControllerBase
    {
        public ProfileController(
            ITempFileCacheManager tempFileCacheManager,
            IProfileAppService profileAppService,
            IImageValidator imageValidator) :
            base(tempFileCacheManager, profileAppService, imageValidator)
        {
        }
    }
}