using Microsoft.Extensions.Configuration;

namespace Business.Solutions.Configuration
{
    public interface IAppConfigurationAccessor
    {
        IConfigurationRoot Configuration { get; }
    }
}
