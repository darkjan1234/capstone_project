using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Domain.Repositories;
using Abp.Runtime.Session;
using Abp.Authorization;
using Business.Solutions.Authorization.Users;
using Business.Solutions.PTT;
using Microsoft.EntityFrameworkCore;

namespace Business.Solutions.PTT
{
    /// <summary>
    /// Service for handling PTT security and region-based access control
    /// </summary>
    public class PttSecurityService : ApplicationService, IPttSecurityService
    {
        private readonly IRepository<PttGroup, long> _pttGroupRepository;
        private readonly IRepository<User, long> _userRepository;

        public PttSecurityService(
            IRepository<PttGroup, long> pttGroupRepository,
            IRepository<User, long> userRepository)
        {
            _pttGroupRepository = pttGroupRepository;
            _userRepository = userRepository;
        }

        /// <summary>
        /// Get all groups that the current user can access based on their region
        /// </summary>
        public async Task<List<object>> GetAccessibleGroupsAsync()
        {
            var currentUser = await GetCurrentUserAsync();
            
            // Super Admin can see all groups
            if (await IsCurrentUserSuperAdminAsync())
            {
                var allGroups = await _pttGroupRepository.GetAllListAsync();
                return allGroups.Cast<object>().ToList();
            }

            // PPO Admin can see groups in their region
            if (await IsCurrentUserPpoAdminAsync())
            {
                var regionGroups = await _pttGroupRepository
                    .GetAll()
                    .Where(g => g.RegionCode == currentUser.RegionCode)
                    .ToListAsync();
                return regionGroups.Cast<object>().ToList();
            }

            // Regular users can only see groups they are members of in their region
            var userGroups = await _pttGroupRepository
                .GetAll()
                .Where(g => g.RegionCode == currentUser.RegionCode &&
                           g.Members.Any(m => m.UserId == AbpSession.UserId))
                .ToListAsync();
            return userGroups.Cast<object>().ToList();
        }

        /// <summary>
        /// Check if current user can communicate with a specific group
        /// </summary>
        public async Task<bool> CanCommunicateWithGroupAsync(long groupId)
        {
            var currentUser = await GetCurrentUserAsync();
            var targetGroup = await _pttGroupRepository.GetAsync(groupId);

            // Super Admin can communicate with everyone
            if (await IsCurrentUserSuperAdminAsync())
                return true;

            // Users can only communicate within their region
            return currentUser.RegionCode == targetGroup.RegionCode;
        }

        /// <summary>
        /// Get users that the current user can communicate with
        /// </summary>
        public async Task<List<User>> GetCommunicableUsersAsync()
        {
            var currentUser = await GetCurrentUserAsync();

            // Super Admin can communicate with everyone
            if (await IsCurrentUserSuperAdminAsync())
            {
                return await _userRepository
                    .GetAll()
                    .Where(u => !string.IsNullOrEmpty(u.PttRole))
                    .ToListAsync();
            }

            // Users can only communicate within their region
            return await _userRepository
                .GetAll()
                .Where(u => u.RegionCode == currentUser.RegionCode && 
                           !string.IsNullOrEmpty(u.PttRole))
                .ToListAsync();
        }

        /// <summary>
        /// Check if current user is Super Admin
        /// </summary>
        public async Task<bool> IsCurrentUserSuperAdminAsync()
        {
            var currentUser = await GetCurrentUserAsync();
            return string.IsNullOrEmpty(currentUser.RegionCode) && 
                   currentUser.PttRole == "SuperAdmin";
        }

        /// <summary>
        /// Check if current user is PPO Admin
        /// </summary>
        public async Task<bool> IsCurrentUserPpoAdminAsync()
        {
            var currentUser = await GetCurrentUserAsync();
            return !string.IsNullOrEmpty(currentUser.RegionCode) && 
                   currentUser.PttRole == "PPOAdmin";
        }

        /// <summary>
        /// Check if current user is Field User
        /// </summary>
        public async Task<bool> IsCurrentUserFieldUserAsync()
        {
            var currentUser = await GetCurrentUserAsync();
            return !string.IsNullOrEmpty(currentUser.RegionCode) && 
                   currentUser.PttRole == "FieldUser";
        }

        /// <summary>
        /// Create a new PPO region (only Super Admin can do this)
        /// </summary>
        public async Task<object> CreatePpoRegionAsync(string regionName, string regionCode, long ppoAdminUserId)
        {
            // Only Super Admin can create PPO regions
            if (!await IsCurrentUserSuperAdminAsync())
                throw new Abp.Authorization.AbpAuthorizationException("Only Super Admin can create PPO regions");

            var ppoGroup = new PttGroup
            {
                Name = regionName,
                Description = $"PPO {regionName} Regional Office",
                RegionCode = regionCode.ToUpper(),
                GroupType = PttGroupType.PPO_Region,
                CreatedByAdminId = AbpSession.GetUserId(),
                IsActive = true,
                HierarchyLevel = 0
            };

            // Set the PPO Admin for this region
            var ppoAdmin = await _userRepository.GetAsync(ppoAdminUserId);
            ppoAdmin.RegionCode = regionCode.ToUpper();
            ppoAdmin.PttRole = "PPOAdmin";

            await _pttGroupRepository.InsertAsync(ppoGroup);
            await _userRepository.UpdateAsync(ppoAdmin);

            return ppoGroup;
        }

        /// <summary>
        /// Assign user to a region (only Super Admin or PPO Admin can do this)
        /// </summary>
        public async Task AssignUserToRegionAsync(long userId, string regionCode, string pttRole)
        {
            var currentUser = await GetCurrentUserAsync();
            var targetUser = await _userRepository.GetAsync(userId);

            // Super Admin can assign anyone to any region
            if (await IsCurrentUserSuperAdminAsync())
            {
                targetUser.RegionCode = regionCode?.ToUpper();
                targetUser.PttRole = pttRole;
                await _userRepository.UpdateAsync(targetUser);
                return;
            }

            // PPO Admin can only assign users to their own region
            if (await IsCurrentUserPpoAdminAsync() && currentUser.RegionCode == regionCode?.ToUpper())
            {
                targetUser.RegionCode = regionCode.ToUpper();
                targetUser.PttRole = pttRole;
                await _userRepository.UpdateAsync(targetUser);
                return;
            }

            throw new Abp.Authorization.AbpAuthorizationException("You don't have permission to assign users to this region");
        }

        private async Task<User> GetCurrentUserAsync()
        {
            return await _userRepository.GetAsync(AbpSession.GetUserId());
        }
    }
}
