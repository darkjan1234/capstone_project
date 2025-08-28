using System.Linq;
using Abp.Authorization.Users;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;
using Business.Solutions.Authorization.Roles;
using Business.Solutions.Authorization.Users;
using Business.Solutions.EntityFrameworkCore;

namespace Business.Solutions.Migrations.Seed.Tenants
{
    public class PttTestUsersBuilder
    {
        private readonly SolutionsDbContext _context;
        private readonly int _tenantId;

        public PttTestUsersBuilder(SolutionsDbContext context, int tenantId)
        {
            _context = context;
            _tenantId = tenantId;
        }

        public void Create()
        {
            CreateTestUsers();
        }

        private void CreateTestUsers()
        {
            var userRole = _context.Roles.FirstOrDefault(r => r.TenantId == _tenantId && r.Name == StaticRoleNames.Tenants.User);
            if (userRole == null) return;

            // Test users for PTT system
            var testUsers = new[]
            {
                new { Username = "user1", Email = "user1@test.com", Name = "Test", Surname = "User1" },
                new { Username = "user2", Email = "user2@test.com", Name = "Test", Surname = "User2" },
                new { Username = "radio1", Email = "radio1@test.com", Name = "Radio", Surname = "Operator1" },
                new { Username = "radio2", Email = "radio2@test.com", Name = "Radio", Surname = "Operator2" },
                new { Username = "ptt1", Email = "ptt1@test.com", Name = "PTT", Surname = "User1" },
                new { Username = "ptt2", Email = "ptt2@test.com", Name = "PTT", Surname = "User2" },
            };

            foreach (var userData in testUsers)
            {
                var existingUser = _context.Users.FirstOrDefault(u => 
                    u.TenantId == _tenantId && u.UserName == userData.Username);
                
                if (existingUser == null)
                {
                    var user = new User
                    {
                        TenantId = _tenantId,
                        UserName = userData.Username,
                        Name = userData.Name,
                        Surname = userData.Surname,
                        EmailAddress = userData.Email,
                        IsEmailConfirmed = true,
                        IsActive = true,
                        ShouldChangePasswordOnNextLogin = false,
                        Password = new PasswordHasher<User>(new OptionsWrapper<PasswordHasherOptions>(new PasswordHasherOptions()))
                            .HashPassword(null, "123qwe") // Default password for all test users
                    };

                    user.SetNormalizedNames();

                    _context.Users.Add(user);
                    _context.SaveChanges();

                    // Assign User role
                    _context.UserRoles.Add(new UserRole(_tenantId, user.Id, userRole.Id));
                    _context.SaveChanges();

                    // Add to UserAccounts table
                    _context.UserAccounts.Add(new UserAccount
                    {
                        TenantId = _tenantId,
                        UserId = user.Id,
                        UserName = user.UserName,
                        EmailAddress = user.EmailAddress
                    });
                    _context.SaveChanges();
                }
            }
        }
    }
}
