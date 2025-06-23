using Microsoft.Extensions.Configuration;
using System.Reflection;
using Business.Solutions.Core;

namespace Business.Solutions.Mobile.MAUI
{
    public static class MauiProgram
    {
        public static MauiApp CreateMauiApp()
        {
            var builder = MauiApp.CreateBuilder();
            builder
                .UseMauiApp<App>()
                .ConfigureFonts(fonts =>
                {
                    fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
                });

            builder.Services.AddMauiBlazorWebView();
#if DEBUG
            builder.Services.AddBlazorWebViewDeveloperTools();
#endif
            ApplicationBootstrapper.InitializeIfNeeds<SolutionsMobileMAUIModule>();

            var app = builder.Build();
            return app;
        }
    }
}