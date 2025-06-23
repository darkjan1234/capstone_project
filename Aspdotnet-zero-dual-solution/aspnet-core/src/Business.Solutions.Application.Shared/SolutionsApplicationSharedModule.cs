using Abp.Modules;
using Abp.Reflection.Extensions;

namespace Business.Solutions
{
    [DependsOn(typeof(SolutionsCoreSharedModule))]
    public class SolutionsApplicationSharedModule : AbpModule
    {
        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(SolutionsApplicationSharedModule).GetAssembly());
        }
    }
}