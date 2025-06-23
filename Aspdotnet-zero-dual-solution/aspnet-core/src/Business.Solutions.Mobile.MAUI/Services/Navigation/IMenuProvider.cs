using Business.Solutions.Models.NavigationMenu;

namespace Business.Solutions.Services.Navigation
{
    public interface IMenuProvider
    {
        List<NavigationMenuItem> GetAuthorizedMenuItems(Dictionary<string, string> grantedPermissions);
    }
}