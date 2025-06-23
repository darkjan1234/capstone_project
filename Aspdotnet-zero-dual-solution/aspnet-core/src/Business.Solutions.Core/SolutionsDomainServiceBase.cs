using Abp.Domain.Services;

namespace Business.Solutions
{
    public abstract class SolutionsDomainServiceBase : DomainService
    {
        /* Add your common members for all your domain services. */

        protected SolutionsDomainServiceBase()
        {
            LocalizationSourceName = SolutionsConsts.LocalizationSourceName;
        }
    }
}
