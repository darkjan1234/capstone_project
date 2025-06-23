using Abp.Dependency;
using Abp.Reflection.Extensions;
using Microsoft.Extensions.Configuration;
using Business.Solutions.Configuration;

namespace Business.Solutions.Test.Base
{
    public class TestAppConfigurationAccessor : IAppConfigurationAccessor, ISingletonDependency
    {
        public IConfigurationRoot Configuration { get; }

        public TestAppConfigurationAccessor()
        {
            Configuration = AppConfigurations.Get(
                typeof(SolutionsTestBaseModule).GetAssembly().GetDirectoryPathOrNull()
            );
        }
    }
}
