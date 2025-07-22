using System;
using System.IO;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Domain.Repositories;
using Business.Solutions.Maintenance;
using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using Abp.Authorization;
using Business.Solutions.Authorization;
using System.Linq;
using Microsoft.EntityFrameworkCore;

namespace Business.Solutions.PTT
{
    [AbpAuthorize(AppPermissions.Pages_Administration)]
    public class PttService : ApplicationService, IPttService
    {
        private readonly IRepository<PTTMessage, Guid> _pttMessageRepository;
        private readonly IRepository<Group, Guid> _groupRepository;
        private readonly IRepository<PttUser, Guid> _pttUserRepository;

        public PttService(
            IRepository<PTTMessage, Guid> pttMessageRepository,
            IRepository<Group, Guid> groupRepository,
            IRepository<PttUser, Guid> pttUserRepository)
        {
            _pttMessageRepository = pttMessageRepository;
            _groupRepository = groupRepository;
            _pttUserRepository = pttUserRepository;
        }



        public async Task<string> SaveAudioFromBase64(string base64Audio, int senderId, int receiverId, int groupId, int durationSeconds)
        {
            if (string.IsNullOrEmpty(base64Audio))
                throw new ArgumentException("Audio data is required");

            // Remove data URL prefix if present
            if (base64Audio.Contains(","))
            {
                base64Audio = base64Audio.Split(',')[1];
            }

            var audioBytes = Convert.FromBase64String(base64Audio);

            // Create directory if it doesn't exist
            var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "audio-messages");
            if (!Directory.Exists(uploadsPath))
            {
                Directory.CreateDirectory(uploadsPath);
            }

            // Generate unique filename
            var fileName = $"{Guid.NewGuid()}_{DateTime.UtcNow:yyyyMMdd_HHmmss}.wav";
            var filePath = Path.Combine(uploadsPath, fileName);

            // Save file
            await File.WriteAllBytesAsync(filePath, audioBytes);

            // Save to database
            var pttMessage = new PTTMessage
            {
                Id = Guid.NewGuid(),
                SenderId = senderId,
                ReceiverId = receiverId,
                GroupId = groupId,
                AudioPath = $"/audio-messages/{fileName}",
                DurationSeconds = durationSeconds,
                TenantId = AbpSession.TenantId
            };

            await _pttMessageRepository.InsertAsync(pttMessage);
            await CurrentUnitOfWork.SaveChangesAsync();

            return pttMessage.AudioPath;
        }

        public async Task<List<PttAudioMessageDto>> GetGroupMessages(int groupId, int skipCount = 0, int maxResultCount = 20)
        {
            var messages = await _pttMessageRepository.GetAll()
                .Where(m => m.GroupId == groupId)
                .OrderByDescending(m => m.CreationTime)
                .Skip(skipCount)
                .Take(maxResultCount)
                .ToListAsync();

            return messages.Select(m => new PttAudioMessageDto
            {
                Id = m.Id,
                SenderId = m.SenderId,
                ReceiverId = m.ReceiverId,
                GroupId = m.GroupId,
                AudioPath = m.AudioPath,
                DurationSeconds = m.DurationSeconds,
                CreationTime = m.CreationTime
            }).ToList();
        }

        public async Task<List<PttGroupDto>> GetUserGroups(int userId)
        {
            // For now, return all groups. In a real implementation, 
            // you'd filter based on group membership
            var groups = await _groupRepository.GetAll()
                .ToListAsync();

            return groups.Select(g => new PttGroupDto
            {
                Id = g.Id,
                Name = g.Name
            }).ToList();
        }

        public async Task<bool> DeleteAudioMessage(Guid messageId)
        {
            var message = await _pttMessageRepository.GetAsync(messageId);
            if (message == null) return false;

            // Delete physical file
            var filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", message.AudioPath.TrimStart('/'));
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }

            // Delete from database
            await _pttMessageRepository.DeleteAsync(messageId);
            await CurrentUnitOfWork.SaveChangesAsync();

            return true;
        }
    }


}
