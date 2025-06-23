using Abp.Modules;
using Abp.Reflection.Extensions;

namespace Business.Solutions
{
    public class SolutionsClientModule : AbpModule
    {
        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(SolutionsClientModule).GetAssembly());
        }
    }
}
