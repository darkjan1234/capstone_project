using Abp.Domain.Services;

namespace Business.Solutions.Authorization.Users.Password
{
    public interface IPasswordExpirationService : IDomainService
    {
        void ForcePasswordExpiredUsersToChangeTheirPassword();
    }
}
