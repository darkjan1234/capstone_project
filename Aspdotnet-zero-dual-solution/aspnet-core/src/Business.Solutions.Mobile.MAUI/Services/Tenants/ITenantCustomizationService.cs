namespace Business.Solutions.Mobile.MAUI.Services.Tenants
{
    public interface ITenantCustomizationService
    {
        Task<string> GetTenantLogo();
    }
}