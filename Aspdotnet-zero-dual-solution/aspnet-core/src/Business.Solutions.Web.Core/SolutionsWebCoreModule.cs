using System;
using System.IO;
using System.Linq;
using System.Text;
using Abp.AspNetCore;
using Abp.AspNetCore.Configuration;
using Abp.AspNetCore.MultiTenancy;
using Abp.AspNetCore.SignalR;
using Abp.AspNetZeroCore.Licensing;
using Abp.AspNetZeroCore.Web;
using Abp.Configuration.Startup;
using Abp.Dependency;
using Abp.Domain.Entities;
using Abp.Hangfire;
using Abp.Hangfire.Configuration;
using Abp.IO;
using Abp.Modules;
using Abp.MultiTenancy;
using Abp.Reflection.Extensions;
using Abp.Runtime.Caching.Redis;
using Abp.Text;
using Abp.Timing;
using Abp.Web.MultiTenancy;
using Abp.Zero.Configuration;
using Castle.Core.Internal;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.ApplicationParts;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Business.Solutions.Authentication.TwoFactor;
using Business.Solutions.Chat;
using Business.Solutions.Configuration;
using Business.Solutions.EntityFrameworkCore;
using Business.Solutions.Startup;
using Business.Solutions.Web.Authentication.JwtBearer;
using Business.Solutions.Web.Authentication.TwoFactor;
using Business.Solutions.Web.Chat.SignalR;
using Business.Solutions.Web.Common;
using Business.Solutions.Web.Configuration;
using Business.Solutions.Web.DashboardCustomization;
using Abp.Extensions;
using Abp.HtmlSanitizer;
using Abp.HtmlSanitizer.Configuration;
using Business.Solutions.Authorization.Accounts;

namespace Business.Solutions.Web
{
    [DependsOn(
        typeof(SolutionsApplicationModule),
        typeof(SolutionsEntityFrameworkCoreModule),
        typeof(AbpAspNetZeroCoreWebModule),
        typeof(AbpAspNetCoreSignalRModule),
        typeof(SolutionsGraphQLModule),
        typeof(AbpRedisCacheModule), //AbpRedisCacheModule dependency (and Abp.RedisCache nuget package) can be removed if not using Redis cache
        typeof(AbpHangfireAspNetCoreModule), //AbpHangfireModule dependency (and Abp.Hangfire.AspNetCore nuget package) can be removed if not using Hangfire
        typeof(AbpHtmlSanitizerModule)
    )]
    public class SolutionsWebCoreModule : AbpModule
    {
        private readonly IWebHostEnvironment _env;
        private readonly IConfigurationRoot _appConfiguration;

        public SolutionsWebCoreModule(IWebHostEnvironment env)
        {
            _env = env;
            _appConfiguration = env.GetAppConfiguration();
        }

        public override void PreInitialize()
        {
            //Set default connection string
            Configuration.DefaultNameOrConnectionString = _appConfiguration.GetConnectionString(
                SolutionsConsts.ConnectionStringName
            );

            //Use database for language management
            Configuration.Modules.Zero().LanguageManagement.EnableDbLocalization();

            Configuration.Modules.AbpAspNetCore()
                .CreateControllersForAppServices(
                    typeof(SolutionsApplicationModule).GetAssembly()
                );

            Configuration.Caching.Configure(TwoFactorCodeCacheItem.CacheName,
                cache => { cache.DefaultSlidingExpireTime = TwoFactorCodeCacheItem.DefaultSlidingExpireTime; });

            if (_appConfiguration["Authentication:JwtBearer:IsEnabled"] != null &&
                bool.Parse(_appConfiguration["Authentication:JwtBearer:IsEnabled"]))
            {
                ConfigureTokenAuth();
            }

            Configuration.ReplaceService<IAppConfigurationAccessor, AppConfigurationAccessor>();

            Configuration.ReplaceService<IAppConfigurationWriter, AppConfigurationWriter>();

            if (WebConsts.HangfireDashboardEnabled)
            {
                Configuration.BackgroundJobs.UseHangfire();
            }

            //Uncomment this line to use Redis cache instead of in-memory cache.
            //See app.config for Redis configuration and connection string
            //Configuration.Caching.UseRedis(options =>
            //{
            //    options.ConnectionString = _appConfiguration["Abp:RedisCache:ConnectionString"];
            //    options.DatabaseId = _appConfiguration.GetValue<int>("Abp:RedisCache:DatabaseId");
            //});

            // HTML Sanitizer configuration
            Configuration.Modules.AbpHtmlSanitizer()
                .KeepChildNodes()
                .AddSelector<IAccountAppService>(x => nameof(x.IsTenantAvailable))
                .AddSelector<IAccountAppService>(x => nameof(x.Register));
        }

        private void ConfigureTokenAuth()
        {
            IocManager.Register<TokenAuthConfiguration>();
            var tokenAuthConfig = IocManager.Resolve<TokenAuthConfiguration>();

            tokenAuthConfig.SecurityKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_appConfiguration["Authentication:JwtBearer:SecurityKey"])
            );

            tokenAuthConfig.Issuer = _appConfiguration["Authentication:JwtBearer:Issuer"];
            tokenAuthConfig.Audience = _appConfiguration["Authentication:JwtBearer:Audience"];
            tokenAuthConfig.SigningCredentials =
                new SigningCredentials(tokenAuthConfig.SecurityKey, SecurityAlgorithms.HmacSha256);
            tokenAuthConfig.AccessTokenExpiration = AppConsts.AccessTokenExpiration;
            tokenAuthConfig.RefreshTokenExpiration = AppConsts.RefreshTokenExpiration;
        }

        public override void Initialize()
        {
            IocManager.RegisterAssemblyByConvention(typeof(SolutionsWebCoreModule).GetAssembly());
        }

        public override void PostInitialize()
        {
            SetAppFolders();

            IocManager.Resolve<ApplicationPartManager>()
                .AddApplicationPartsIfNotAddedBefore(typeof(SolutionsWebCoreModule).Assembly);
        }

        private void SetAppFolders()
        {
            var appFolders = IocManager.Resolve<AppFolders>();

            appFolders.SampleProfileImagesFolder = Path.Combine(_env.WebRootPath,
                $"Common{Path.DirectorySeparatorChar}Images{Path.DirectorySeparatorChar}SampleProfilePics");
            appFolders.WebLogsFolder = Path.Combine(_env.ContentRootPath, $"App_Data{Path.DirectorySeparatorChar}Logs");
        }
    }
}