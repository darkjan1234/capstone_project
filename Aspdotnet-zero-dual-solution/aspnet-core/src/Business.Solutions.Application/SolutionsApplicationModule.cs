using Abp.AutoMapper;
using Abp.Modules;
using Abp.Reflection.Extensions;
using Business.Solutions.Authorization;

namespace Business.Solutions
{
    /// <summary>
    /// Application layer module of the application.
    /// </summary>
    [DependsOn(
        typeof(SolutionsApplicationSharedModule),
        typeof(SolutionsCoreModule)
        )]
    public class SolutionsApplicationModule : AbpModule
    {
        public override void PreInitialize()
        {
            //Adding authorization providers
            Configuration.Authorization.Providers.Add<AppAuthorizationProvider>();

            //Adding custom AutoMapper configuration
            Configuration.Modules.AbpAutoMapper().Configurators.Add(CustomDtoMapper.CreateMappings);
        }

        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(SolutionsApplicationModule).GetAssembly());
        }
    }
}