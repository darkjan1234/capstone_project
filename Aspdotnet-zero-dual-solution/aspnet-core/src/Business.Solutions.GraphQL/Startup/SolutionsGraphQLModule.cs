using Abp.AutoMapper;
using Abp.Modules;
using Abp.Reflection.Extensions;

namespace Business.Solutions.Startup
{
    [DependsOn(typeof(SolutionsCoreModule))]
    public class SolutionsGraphQLModule : AbpModule
    {
        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(SolutionsGraphQLModule).GetAssembly());
        }

        public override void PreInitialize()
        {
            base.PreInitialize();

            //Adding custom AutoMapper configuration
            Configuration.Modules.AbpAutoMapper().Configurators.Add(CustomDtoMapper.CreateMappings);
        }
    }
}