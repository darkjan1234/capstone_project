namespace Business.Solutions.Services.Permission
{
    public interface IPermissionService
    {
        bool HasPermission(string key);
    }
}