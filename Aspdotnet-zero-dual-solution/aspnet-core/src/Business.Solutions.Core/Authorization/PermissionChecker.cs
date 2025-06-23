using Abp.Authorization;
using Business.Solutions.Authorization.Roles;
using Business.Solutions.Authorization.Users;

namespace Business.Solutions.Authorization
{
    public class PermissionChecker : PermissionChecker<Role, User>
    {
        public PermissionChecker(UserManager userManager)
            : base(userManager)
        {

        }
    }
}
