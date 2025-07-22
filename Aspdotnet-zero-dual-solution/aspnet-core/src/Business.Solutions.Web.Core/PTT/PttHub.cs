using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Abp.AspNetCore.SignalR.Hubs;
using Abp.Runtime.Session;
using Microsoft.AspNetCore.Authorization;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using Abp.RealTime;

namespace Business.Solutions.Web.PTT
{
    [Authorize]
    public class PttHub : OnlineClientHubBase
    {
        // Store connected users and their groups
        private static readonly ConcurrentDictionary<string, UserConnection> ConnectedUsers = new();
        private static readonly ConcurrentDictionary<string, HashSet<string>> GroupConnections = new();

        public PttHub(
            IOnlineClientManager onlineClientManager,
            IOnlineClientInfoProvider clientInfoProvider) : base(onlineClientManager, clientInfoProvider)
        {
        }

        public async Task JoinGroup(string groupName)
        {
            var userId = AbpSession.UserId?.ToString();
            if (userId == null) return;

            var connectionId = Context.ConnectionId;

            // Add user to group
            await Groups.AddToGroupAsync(connectionId, groupName);

            // Track the connection
            ConnectedUsers[connectionId] = new UserConnection
            {
                UserId = userId,
                GroupName = groupName,
                ConnectionId = connectionId
            };

            // Track group connections
            if (!GroupConnections.ContainsKey(groupName))
            {
                GroupConnections[groupName] = new HashSet<string>();
            }
            GroupConnections[groupName].Add(connectionId);

            // Notify group members that user joined
            await Clients.Group(groupName).SendAsync("UserJoined", new
            {
                UserId = userId,
                Message = $"User {userId} joined the group"
            });

            // Send current group members to the new user
            var groupMembers = GetGroupMembers(groupName);
            await Clients.Caller.SendAsync("GroupMembers", groupMembers);
        }

        public async Task LeaveGroup(string groupName)
        {
            var connectionId = Context.ConnectionId;

            if (ConnectedUsers.TryGetValue(connectionId, out var userConnection))
            {
                await Groups.RemoveFromGroupAsync(connectionId, groupName);

                // Remove from tracking
                ConnectedUsers.TryRemove(connectionId, out _);
                if (GroupConnections.ContainsKey(groupName))
                {
                    GroupConnections[groupName].Remove(connectionId);
                    if (!GroupConnections[groupName].Any())
                    {
                        GroupConnections.TryRemove(groupName, out _);
                    }
                }

                // Notify group members that user left
                await Clients.Group(groupName).SendAsync("UserLeft", new
                {
                    UserId = userConnection.UserId,
                    Message = $"User {userConnection.UserId} left the group"
                });
            }
        }

        public async Task StartTalking(string groupName)
        {
            var userId = AbpSession.UserId?.ToString();
            if (userId == null) return;

            // Notify group members that user started talking
            await Clients.Group(groupName).SendAsync("UserStartedTalking", new
            {
                UserId = userId,
                Timestamp = DateTime.UtcNow
            });
        }

        public async Task StopTalking(string groupName)
        {
            var userId = AbpSession.UserId?.ToString();
            if (userId == null) return;

            // Notify group members that user stopped talking
            await Clients.Group(groupName).SendAsync("UserStoppedTalking", new
            {
                UserId = userId,
                Timestamp = DateTime.UtcNow
            });
        }

        public async Task SendAudioData(string groupName, string audioData, int duration)
        {
            var userId = AbpSession.UserId?.ToString();
            if (userId == null) return;

            // Broadcast audio data to all group members except sender
            await Clients.GroupExcept(groupName, Context.ConnectionId).SendAsync("ReceiveAudio", new
            {
                UserId = userId,
                AudioData = audioData,
                Duration = duration,
                Timestamp = DateTime.UtcNow
            });
        }

        public override async Task OnDisconnectedAsync(Exception exception)
        {
            var connectionId = Context.ConnectionId;

            if (ConnectedUsers.TryGetValue(connectionId, out var userConnection))
            {
                await LeaveGroup(userConnection.GroupName);
            }

            await base.OnDisconnectedAsync(exception);
        }

        private List<object> GetGroupMembers(string groupName)
        {
            if (!GroupConnections.ContainsKey(groupName))
                return new List<object>();

            return GroupConnections[groupName]
                .Where(connId => ConnectedUsers.ContainsKey(connId))
                .Select(connId => new
                {
                    UserId = ConnectedUsers[connId].UserId,
                    ConnectionId = connId
                })
                .Cast<object>()
                .ToList();
        }
    }

    public class UserConnection
    {
        public string UserId { get; set; }
        public string GroupName { get; set; }
        public string ConnectionId { get; set; }
    }
}
