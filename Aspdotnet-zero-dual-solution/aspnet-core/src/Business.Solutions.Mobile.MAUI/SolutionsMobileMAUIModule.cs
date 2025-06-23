using Abp.AutoMapper;
using Abp.Configuration.Startup;
using Abp.Modules;
using Abp.Reflection.Extensions;
using Business.Solutions.ApiClient;
using Business.Solutions.Mobile.MAUI.Core.ApiClient;

namespace Business.Solutions
{
    [DependsOn(typeof(SolutionsClientModule), typeof(AbpAutoMapperModule))]

    public class SolutionsMobileMAUIModule : AbpModule
    {
        public override void PreInitialize()
        {
            Configuration.Localization.IsEnabled = false;
            Configuration.BackgroundJobs.IsJobExecutionEnabled = false;

            Configuration.ReplaceService<IApplicationContext, MAUIApplicationContext>();
        }

        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(SolutionsMobileMAUIModule).GetAssembly());
        }
    }
}