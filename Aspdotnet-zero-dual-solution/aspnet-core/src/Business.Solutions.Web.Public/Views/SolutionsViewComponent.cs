using Abp.AspNetCore.Mvc.ViewComponents;

namespace Business.Solutions.Web.Public.Views
{
    public abstract class SolutionsViewComponent : AbpViewComponent
    {
        protected SolutionsViewComponent()
        {
            LocalizationSourceName = SolutionsConsts.LocalizationSourceName;
        }
    }
}