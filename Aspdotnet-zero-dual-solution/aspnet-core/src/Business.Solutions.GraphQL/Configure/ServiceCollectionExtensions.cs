using System.Collections.Generic;
using System.Threading.Tasks;
using GraphQL;
using GraphQL.Server;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.DependencyInjection;
using Business.Solutions.Debugging;
using Business.Solutions.Schemas;

namespace Business.Solutions.Configure
{
    public static class ServiceCollectionExtensions
    {
        public static void AddAndConfigureGraphQL(this IServiceCollection services)
        {
            services
                .AddGraphQL(x => x.AddNewtonsoftJson()
                    .AddErrorInfoProvider(opt => opt.ExposeExceptionDetails = DebugHelper.IsDebug)
                    .AddGraphTypes()
                    .AddDataLoader()
                    .AddUserContextBuilder(httpContext => new Dictionary<string, object>
                    {
                        {"user", httpContext.User}
                    })
                );

            AllowSynchronousIo(services);
        }

        //https://github.com/graphql-dotnet/graphql-dotnet/issues/1326
        private static void AllowSynchronousIo(IServiceCollection services)
        {
            // kestrel
            services.Configure<KestrelServerOptions>(options => { options.AllowSynchronousIO = true; });

            // IIS
            services.Configure<IISServerOptions>(options => { options.AllowSynchronousIO = true; });
        }
    }
}