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
        /// Test endpoint to check basic database access
        /// </summary>
        [HttpGet("check-database")]
        public async Task<IActionResult> CheckDatabase()
        {
            try
            {
                var users = await _userRepository.GetAllListAsync();
                var groups = await _pttGroupRepository.GetAllListAsync();

                var result = new
                {
                    Success = true,
                    Message = "Database is accessible",
                    UserCount = users.Count,
                    GroupCount = groups.Count,
                    Note = "RegionCode and PttRole properties will be available after database migration"
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
        /// Get current user's basic info
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
                    EmailAddress = currentUser.EmailAddress,
                    IsActive = currentUser.IsActive,
                    Note = "RegionCode and PttRole will be available after database migration"
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
        /// Get all groups (temporary - before regional security)
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

                var accessibleGroups = allGroups.Select(g => new
                {
                    g.Id,
                    g.Name,
                    g.Description,
                    g.GroupType,
                    g.IsActive,
                    g.HierarchyLevel
                }).ToList();

                return Ok(new
                {
                    Success = true,
                    UserName = currentUser.UserName,
                    GroupCount = accessibleGroups.Count,
                    Groups = accessibleGroups,
                    Note = "Regional filtering will be available after database migration"
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
        /// Basic user info comparison (temporary)
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

                return Ok(new
                {
                    CanCommunicate = true, // Temporary - all users can communicate
                    Reason = "Regional restrictions will be applied after database migration",
                    CurrentUser = new
                    {
                        currentUser.UserName,
                        currentUser.Name,
                        currentUser.EmailAddress
                    },
                    TargetUser = new
                    {
                        targetUser.UserName,
                        targetUser.Name,
                        targetUser.EmailAddress
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
    }
}
