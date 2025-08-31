using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Abp.Runtime.Session;
using Abp.Domain.Repositories;
using Business.Solutions.Authorization.Users;
using Business.Solutions.PTT;
using Microsoft.Extensions.Logging;

namespace Business.Solutions.PTT
{
    /// <summary>
    /// SignalR Hub for real-time Push-to-Talk voice transmission
    /// </summary>
    public class PttVoiceHub : Hub
    {
        private readonly IAbpSession _abpSession;
        private readonly IRepository<User, long> _userRepository;
        private readonly IRepository<PttGroup, long> _groupRepository;
        private readonly ILogger<PttVoiceHub> _logger;

        // Static dictionary to track connected users and their groups
        private static readonly Dictionary<string, PttUserConnection> ConnectedUsers = new();
        private static readonly Dictionary<long, List<string>> GroupConnections = new();

        public PttVoiceHub(
            IAbpSession abpSession,
            IRepository<User, long> userRepository,
            IRepository<PttGroup, long> groupRepository,
            ILogger<PttVoiceHub> logger)
        {
            _abpSession = abpSession;
            _userRepository = userRepository;
            _groupRepository = groupRepository;
            _logger = logger;
        }

        /// <summary>
        /// User connects to PTT system
        /// </summary>
        public async Task JoinPttSystem(long userId, string userName)
        {
            try
            {
                var connectionId = Context.ConnectionId;
                
                // Add user to connected users
                ConnectedUsers[connectionId] = new PttUserConnection
                {
                    UserId = userId,
                    UserName = userName,
                    ConnectionId = connectionId,
                    ConnectedAt = DateTime.UtcNow
                };

                // Get user's groups and join them
                var userGroups = await GetUserGroups(userId);
                foreach (var group in userGroups)
                {
                    await Groups.AddToGroupAsync(connectionId, $"Group_{group.Id}");
                    
                    // Track group connections
                    if (!GroupConnections.ContainsKey(group.Id))
                        GroupConnections[group.Id] = new List<string>();
                    
                    if (!GroupConnections[group.Id].Contains(connectionId))
                        GroupConnections[group.Id].Add(connectionId);
                }

                _logger.LogInformation($"User {userName} (ID: {userId}) joined PTT system with {userGroups.Count} groups");

                // Notify others in groups that user is online
                foreach (var group in userGroups)
                {
                    await Clients.Group($"Group_{group.Id}").SendAsync("UserJoined", new
                    {
                        UserId = userId,
                        UserName = userName,
                        GroupId = group.Id,
                        GroupName = group.Name,
                        Timestamp = DateTime.UtcNow
                    });
                }

                // Send current online users to the new user
                var onlineUsers = GetOnlineUsersInGroups(userGroups.Select(g => g.Id).ToList());
                await Clients.Caller.SendAsync("OnlineUsers", onlineUsers);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error in JoinPttSystem for user {userName}");
                throw;
            }
        }

        /// <summary>
        /// Start voice transmission (Push-to-Talk pressed)
        /// </summary>
        public async Task StartTransmission(long groupId, string userName)
        {
            try
            {
                var connectionId = Context.ConnectionId;
                
                if (!ConnectedUsers.ContainsKey(connectionId))
                {
                    await Clients.Caller.SendAsync("Error", "User not connected to PTT system");
                    return;
                }

                var user = ConnectedUsers[connectionId];
                
                _logger.LogInformation($"User {userName} started transmission in group {groupId}");

                // Notify all users in the group that transmission started
                await Clients.Group($"Group_{groupId}").SendAsync("TransmissionStarted", new
                {
                    UserId = user.UserId,
                    UserName = userName,
                    GroupId = groupId,
                    Timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error in StartTransmission for user {userName} in group {groupId}");
                throw;
            }
        }

        /// <summary>
        /// Transmit voice data to group members
        /// </summary>
        public async Task TransmitVoice(long groupId, string audioData, string userName)
        {
            try
            {
                var connectionId = Context.ConnectionId;
                
                if (!ConnectedUsers.ContainsKey(connectionId))
                {
                    await Clients.Caller.SendAsync("Error", "User not connected to PTT system");
                    return;
                }

                var user = ConnectedUsers[connectionId];

                // Send voice data to all other users in the group (except sender)
                await Clients.GroupExcept($"Group_{groupId}", connectionId).SendAsync("ReceiveVoice", new
                {
                    UserId = user.UserId,
                    UserName = userName,
                    GroupId = groupId,
                    AudioData = audioData,
                    Timestamp = DateTime.UtcNow
                });

                // Log transmission (optional - can be disabled for performance)
                // _logger.LogDebug($"Voice data transmitted from {userName} to group {groupId}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error in TransmitVoice for user {userName} in group {groupId}");
                throw;
            }
        }

        /// <summary>
        /// Stop voice transmission (Push-to-Talk released)
        /// </summary>
        public async Task StopTransmission(long groupId, string userName)
        {
            try
            {
                var connectionId = Context.ConnectionId;
                
                if (!ConnectedUsers.ContainsKey(connectionId))
                {
                    await Clients.Caller.SendAsync("Error", "User not connected to PTT system");
                    return;
                }

                var user = ConnectedUsers[connectionId];
                
                _logger.LogInformation($"User {userName} stopped transmission in group {groupId}");

                // Notify all users in the group that transmission stopped
                await Clients.Group($"Group_{groupId}").SendAsync("TransmissionStopped", new
                {
                    UserId = user.UserId,
                    UserName = userName,
                    GroupId = groupId,
                    Timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error in StopTransmission for user {userName} in group {groupId}");
                throw;
            }
        }

        /// <summary>
        /// User disconnects from PTT system
        /// </summary>
        public override async Task OnDisconnectedAsync(Exception exception)
        {
            try
            {
                var connectionId = Context.ConnectionId;
                
                if (ConnectedUsers.ContainsKey(connectionId))
                {
                    var user = ConnectedUsers[connectionId];
                    
                    // Remove from all groups
                    foreach (var groupConnections in GroupConnections.Values)
                    {
                        groupConnections.Remove(connectionId);
                    }

                    // Notify groups that user left
                    var userGroups = await GetUserGroups(user.UserId);
                    foreach (var group in userGroups)
                    {
                        await Clients.Group($"Group_{group.Id}").SendAsync("UserLeft", new
                        {
                            UserId = user.UserId,
                            UserName = user.UserName,
                            GroupId = group.Id,
                            Timestamp = DateTime.UtcNow
                        });
                    }

                    ConnectedUsers.Remove(connectionId);
                    
                    _logger.LogInformation($"User {user.UserName} disconnected from PTT system");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in OnDisconnectedAsync");
            }

            await base.OnDisconnectedAsync(exception);
        }

        /// <summary>
        /// Get groups that user belongs to
        /// </summary>
        private async Task<List<PttGroup>> GetUserGroups(long userId)
        {
            try
            {
                // For now, return all active groups
                // Later, implement proper group membership
                var groups = await _groupRepository.GetAllListAsync(g => g.IsActive);
                return groups;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error getting groups for user {userId}");
                return new List<PttGroup>();
            }
        }

        /// <summary>
        /// Get online users in specified groups
        /// </summary>
        private List<object> GetOnlineUsersInGroups(List<long> groupIds)
        {
            var onlineUsers = new List<object>();
            
            foreach (var user in ConnectedUsers.Values)
            {
                onlineUsers.Add(new
                {
                    user.UserId,
                    user.UserName,
                    user.ConnectedAt,
                    IsOnline = true
                });
            }
            
            return onlineUsers;
        }
    }

    /// <summary>
    /// Represents a connected PTT user
    /// </summary>
    public class PttUserConnection
    {
        public long UserId { get; set; }
        public string UserName { get; set; }
        public string ConnectionId { get; set; }
        public DateTime ConnectedAt { get; set; }
    }
}
