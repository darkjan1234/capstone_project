using Abp.AspNetCore.Mvc.Views;

namespace Business.Solutions.Web.Views
{
    public abstract class SolutionsRazorPage<TModel> : AbpRazorPage<TModel>
    {
        protected SolutionsRazorPage()
        {
            LocalizationSourceName = SolutionsConsts.LocalizationSourceName;
        }
    }
}
