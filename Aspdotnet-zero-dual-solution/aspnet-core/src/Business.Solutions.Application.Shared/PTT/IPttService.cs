using System;
using System.Threading.Tasks;
using Abp.Application.Services;
using System.Collections.Generic;

namespace Business.Solutions.PTT
{
    public interface IPttService : IApplicationService
    {
        Task<string> SaveAudioFromBase64(string base64Audio, int senderId, int receiverId, int groupId, int durationSeconds);
        Task<List<PttAudioMessageDto>> GetGroupMessages(int groupId, int skipCount = 0, int maxResultCount = 20);
        Task<List<PttGroupDto>> GetUserGroups(int userId);
        Task<bool> DeleteAudioMessage(Guid messageId);
    }

    public class PttAudioMessageDto
    {
        public Guid Id { get; set; }
        public int SenderId { get; set; }
        public int ReceiverId { get; set; }
        public int GroupId { get; set; }
        public string AudioPath { get; set; }
        public int DurationSeconds { get; set; }
        public DateTime CreationTime { get; set; }
    }

    public class PttGroupDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
    }
}
