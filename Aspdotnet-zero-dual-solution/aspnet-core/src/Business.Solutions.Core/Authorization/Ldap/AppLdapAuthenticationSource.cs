using Abp.Zero.Ldap.Authentication;
using Abp.Zero.Ldap.Configuration;
using Business.Solutions.Authorization.Users;
using Business.Solutions.MultiTenancy;

namespace Business.Solutions.Authorization.Ldap
{
    public class AppLdapAuthenticationSource : LdapAuthenticationSource<Tenant, User>
    {
        public AppLdapAuthenticationSource(ILdapSettings settings, IAbpZeroLdapModuleConfig ldapModuleConfig)
            : base(settings, ldapModuleConfig)
        {
        }
    }
}