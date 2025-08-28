using System.Collections.Generic;
using System.Threading.Tasks;
using Abp.Application.Services;
using Business.Solutions.Authorization.Users;

namespace Business.Solutions.PTT
{
    /// <summary>
    /// Interface for PTT security and region-based access control
    /// </summary>
    public interface IPttSecurityService : IApplicationService
    {
        /// <summary>
        /// Get all groups that the current user can access based on their region
        /// </summary>
        Task<List<object>> GetAccessibleGroupsAsync();

        /// <summary>
        /// Check if current user can communicate with a specific group
        /// </summary>
        Task<bool> CanCommunicateWithGroupAsync(long groupId);

        /// <summary>
        /// Get users that the current user can communicate with
        /// </summary>
        Task<List<User>> GetCommunicableUsersAsync();

        /// <summary>
        /// Check if current user is Super Admin
        /// </summary>
        Task<bool> IsCurrentUserSuperAdminAsync();

        /// <summary>
        /// Check if current user is PPO Admin
        /// </summary>
        Task<bool> IsCurrentUserPpoAdminAsync();

        /// <summary>
        /// Check if current user is Field User
        /// </summary>
        Task<bool> IsCurrentUserFieldUserAsync();

        /// <summary>
        /// Create a new PPO region (only Super Admin can do this)
        /// </summary>
        Task<object> CreatePpoRegionAsync(string regionName, string regionCode, long ppoAdminUserId);

        /// <summary>
        /// Assign user to a region (only Super Admin or PPO Admin can do this)
        /// </summary>
        Task AssignUserToRegionAsync(long userId, string regionCode, string pttRole);
    }
}
