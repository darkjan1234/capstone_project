using Abp.Modules;
using Abp.Reflection.Extensions;
using Castle.Windsor.MsDependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using Business.Solutions.Configure;
using Business.Solutions.Startup;
using Business.Solutions.Test.Base;

namespace Business.Solutions.GraphQL.Tests
{
    [DependsOn(
        typeof(SolutionsGraphQLModule),
        typeof(SolutionsTestBaseModule))]
    public class SolutionsGraphQLTestModule : AbpModule
    {
        public override void PreInitialize()
        {
            IServiceCollection services = new ServiceCollection();
            
            services.AddAndConfigureGraphQL();

            WindsorRegistrationHelper.CreateServiceProvider(IocManager.IocContainer, services);
        }

        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(SolutionsGraphQLTestModule).GetAssembly());
        }
    }
}