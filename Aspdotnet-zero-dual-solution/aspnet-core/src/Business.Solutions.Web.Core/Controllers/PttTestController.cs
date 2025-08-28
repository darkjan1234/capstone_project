using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Abp.AspNetCore.Mvc.Controllers;
using Abp.Domain.Repositories;
using Business.Solutions.Authorization.Users;
using Business.Solutions.PTT;

namespace Business.Solutions.Web.Controllers
{
    /// <summary>
    /// Simple controller to test PTT regional security
    /// </summary>
    [Route("api/[controller]")]
    public class PttTestController : AbpController
    {
        private readonly IRepository<User, long> _userRepository;
        private readonly IRepository<PttGroup, long> _pttGroupRepository;

        public PttTestController(
            IRepository<User, long> userRepository,
            IRepository<PttGroup, long> pttGroupRepository)
        {
            _userRepository = userRepository;
            _pttGroupRepository = pttGroupRepository;
        }

        /// <summary>
        /// Test endpoint to check if regional columns exist
        /// </summary>
        [HttpGet("check-database")]
        public async Task<IActionResult> CheckDatabase()
        {
            try
            {
                // Try to access RegionCode and PttRole properties
                var users = await _userRepository.GetAllListAsync();
                var groups = await _pttGroupRepository.GetAllListAsync();

                var result = new
                {
                    Success = true,
                    Message = "Database columns exist and are accessible",
                    UserCount = users.Count,
                    GroupCount = groups.Count,
                    UsersWithRegion = users.Count(u => !string.IsNullOrEmpty(u.RegionCode)),
                    UsersWithPttRole = users.Count(u => !string.IsNullOrEmpty(u.PttRole)),
                    GroupsWithRegion = groups.Count(g => !string.IsNullOrEmpty(g.RegionCode))
                };

                return Ok(result);
            }
            catch (System.Exception ex)
            {
                return BadRequest(new
                {
                    Success = false,
                    Message = "Error accessing database",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Get current user's PTT info
        /// </summary>
        [HttpGet("current-user-info")]
        public async Task<IActionResult> GetCurrentUserInfo()
        {
            try
            {
                if (!AbpSession.UserId.HasValue)
                {
                    return Unauthorized(new { Message = "User not logged in" });
                }

                var currentUser = await _userRepository.GetAsync(AbpSession.UserId.Value);

                var result = new
                {
                    UserId = currentUser.Id,
                    UserName = currentUser.UserName,
                    Name = currentUser.Name,
                    RegionCode = currentUser.RegionCode ?? "No Region",
                    PttRole = currentUser.PttRole ?? "No PTT Role",
                    UserType = GetUserType(currentUser),
                    CanAccessAllRegions = string.IsNullOrEmpty(currentUser.RegionCode)
                };

                return Ok(result);
            }
            catch (System.Exception ex)
            {
                return BadRequest(new
                {
                    Success = false,
                    Message = "Error getting user info",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Get groups accessible to current user
        /// </summary>
        [HttpGet("accessible-groups")]
        public async Task<IActionResult> GetAccessibleGroups()
        {
            try
            {
                if (!AbpSession.UserId.HasValue)
                {
                    return Unauthorized(new { Message = "User not logged in" });
                }

                var currentUser = await _userRepository.GetAsync(AbpSession.UserId.Value);
                var allGroups = await _pttGroupRepository.GetAllListAsync();

                List<object> accessibleGroups;

                // Super Admin can see all groups
                if (IsSuperAdmin(currentUser))
                {
                    accessibleGroups = allGroups.Select(g => new
                    {
                        g.Id,
                        g.Name,
                        g.Description,
                        RegionCode = g.RegionCode ?? "No Region",
                        g.GroupType,
                        g.IsActive
                    }).Cast<object>().ToList();
                }
                // PPO Admin can see groups in their region
                else if (IsPpoAdmin(currentUser))
                {
                    accessibleGroups = allGroups
                        .Where(g => g.RegionCode == currentUser.RegionCode)
                        .Select(g => new
                        {
                            g.Id,
                            g.Name,
                            g.Description,
                            RegionCode = g.RegionCode ?? "No Region",
                            g.GroupType,
                            g.IsActive
                        }).Cast<object>().ToList();
                }
                // Field users can see groups they're members of
                else
                {
                    accessibleGroups = allGroups
                        .Where(g => g.RegionCode == currentUser.RegionCode)
                        .Select(g => new
                        {
                            g.Id,
                            g.Name,
                            g.Description,
                            RegionCode = g.RegionCode ?? "No Region",
                            g.GroupType,
                            g.IsActive
                        }).Cast<object>().ToList();
                }

                return Ok(new
                {
                    Success = true,
                    UserType = GetUserType(currentUser),
                    UserRegion = currentUser.RegionCode ?? "All Regions",
                    GroupCount = accessibleGroups.Count,
                    Groups = accessibleGroups
                });
            }
            catch (System.Exception ex)
            {
                return BadRequest(new
                {
                    Success = false,
                    Message = "Error getting accessible groups",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Test communication between users
        /// </summary>
        [HttpGet("can-communicate/{targetUserId}")]
        public async Task<IActionResult> CanCommunicate(long targetUserId)
        {
            try
            {
                if (!AbpSession.UserId.HasValue)
                {
                    return Unauthorized(new { Message = "User not logged in" });
                }

                var currentUser = await _userRepository.GetAsync(AbpSession.UserId.Value);
                var targetUser = await _userRepository.GetAsync(targetUserId);

                bool canCommunicate = false;
                string reason = "";

                // Super Admin can communicate with everyone
                if (IsSuperAdmin(currentUser))
                {
                    canCommunicate = true;
                    reason = "Super Admin can communicate with everyone";
                }
                // Same region users can communicate
                else if (currentUser.RegionCode == targetUser.RegionCode)
                {
                    canCommunicate = true;
                    reason = $"Both users are in {currentUser.RegionCode} region";
                }
                // Different regions cannot communicate
                else
                {
                    canCommunicate = false;
                    reason = $"Different regions: {currentUser.RegionCode} vs {targetUser.RegionCode}";
                }

                return Ok(new
                {
                    CanCommunicate = canCommunicate,
                    Reason = reason,
                    CurrentUser = new
                    {
                        currentUser.UserName,
                        RegionCode = currentUser.RegionCode ?? "All Regions",
                        PttRole = currentUser.PttRole ?? "No Role"
                    },
                    TargetUser = new
                    {
                        targetUser.UserName,
                        RegionCode = targetUser.RegionCode ?? "All Regions",
                        PttRole = targetUser.PttRole ?? "No Role"
                    }
                });
            }
            catch (System.Exception ex)
            {
                return BadRequest(new
                {
                    Success = false,
                    Message = "Error checking communication permission",
                    Error = ex.Message
                });
            }
        }

        private bool IsSuperAdmin(User user)
        {
            return string.IsNullOrEmpty(user.RegionCode) && user.PttRole == "SuperAdmin";
        }

        private bool IsPpoAdmin(User user)
        {
            return !string.IsNullOrEmpty(user.RegionCode) && user.PttRole == "PPOAdmin";
        }

        private string GetUserType(User user)
        {
            if (IsSuperAdmin(user)) return "Super Admin";
            if (IsPpoAdmin(user)) return "PPO Admin";
            if (user.PttRole == "FieldUser") return "Field User";
            return "Regular User";
        }
    }
}
