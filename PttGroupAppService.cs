using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Abp.Domain.Repositories;
using Abp.Linq.Extensions;
using Microsoft.EntityFrameworkCore;
using Business.Solutions.Authorization.Users;

namespace Business.Solutions.PTT
{
    public interface IPttGroupAppService : IApplicationService
    {
        Task<List<PttGroupDto>> GetMyGroups();
        Task<List<PttGroupMemberDto>> GetGroupMembers(long groupId);
        Task<PttGroupDto> CreateGroup(CreatePttGroupInput input);
        Task AddUserToGroup(AddUserToGroupInput input);
        Task RemoveUserFromGroup(RemoveUserFromGroupInput input);
        Task<List<PttGroupDto>> GetAllGroups();
    }

    public class PttGroupAppService : ApplicationService, IPttGroupAppService
    {
        private readonly IRepository<PttGroup, long> _groupRepository;
        private readonly IRepository<PttGroupMember, long> _groupMemberRepository;
        private readonly IRepository<User, long> _userRepository;

        public PttGroupAppService(
            IRepository<PttGroup, long> groupRepository,
            IRepository<PttGroupMember, long> groupMemberRepository,
            IRepository<User, long> userRepository)
        {
            _groupRepository = groupRepository;
            _groupMemberRepository = groupMemberRepository;
            _userRepository = userRepository;
        }

        public async Task<List<PttGroupDto>> GetMyGroups()
        {
            var userId = AbpSession.GetUserId();
            
            var query = from g in _groupRepository.GetAll()
                       join gm in _groupMemberRepository.GetAll() on g.Id equals gm.PttGroupId
                       where gm.UserId == userId && gm.IsActive && g.IsActive
                       select new PttGroupDto
                       {
                           Id = g.Id,
                           Name = g.Name,
                           Description = g.Description,
                           CreatedByAdminId = g.CreatedByAdminId,
                           IsActive = g.IsActive,
                           CreationTime = g.CreationTime
                       };

            return await query.ToListAsync();
        }

        public async Task<List<PttGroupMemberDto>> GetGroupMembers(long groupId)
        {
            var query = from gm in _groupMemberRepository.GetAll()
                       join u in _userRepository.GetAll() on gm.UserId equals u.Id
                       where gm.PttGroupId == groupId && gm.IsActive
                       select new PttGroupMemberDto
                       {
                           Id = gm.Id,
                           PttGroupId = gm.PttGroupId,
                           UserId = gm.UserId,
                           UserName = u.UserName,
                           Name = u.Name,
                           Surname = u.Surname,
                           IsActive = gm.IsActive,
                           JoinedDate = gm.JoinedDate
                       };

            return await query.ToListAsync();
        }

        public async Task<PttGroupDto> CreateGroup(CreatePttGroupInput input)
        {
            var group = new PttGroup
            {
                Name = input.Name,
                Description = input.Description,
                CreatedByAdminId = AbpSession.GetUserId(),
                IsActive = true,
                CreationTime = DateTime.Now
            };

            var savedGroup = await _groupRepository.InsertAsync(group);
            await CurrentUnitOfWork.SaveChangesAsync();

            // Add creator as member
            var membership = new PttGroupMember
            {
                PttGroupId = savedGroup.Id,
                UserId = AbpSession.GetUserId(),
                IsActive = true,
                JoinedDate = DateTime.Now,
                CreationTime = DateTime.Now
            };

            await _groupMemberRepository.InsertAsync(membership);

            return new PttGroupDto
            {
                Id = savedGroup.Id,
                Name = savedGroup.Name,
                Description = savedGroup.Description,
                CreatedByAdminId = savedGroup.CreatedByAdminId,
                IsActive = savedGroup.IsActive,
                CreationTime = savedGroup.CreationTime
            };
        }

        public async Task AddUserToGroup(AddUserToGroupInput input)
        {
            // Check if user is already in group
            var existingMember = await _groupMemberRepository.FirstOrDefaultAsync(
                gm => gm.PttGroupId == input.GroupId && gm.UserId == input.UserId);

            if (existingMember != null)
            {
                existingMember.IsActive = true;
                await _groupMemberRepository.UpdateAsync(existingMember);
            }
            else
            {
                var membership = new PttGroupMember
                {
                    PttGroupId = input.GroupId,
                    UserId = input.UserId,
                    IsActive = true,
                    JoinedDate = DateTime.Now,
                    CreationTime = DateTime.Now
                };

                await _groupMemberRepository.InsertAsync(membership);
            }
        }

        public async Task RemoveUserFromGroup(RemoveUserFromGroupInput input)
        {
            var membership = await _groupMemberRepository.FirstOrDefaultAsync(
                gm => gm.PttGroupId == input.GroupId && gm.UserId == input.UserId);

            if (membership != null)
            {
                membership.IsActive = false;
                await _groupMemberRepository.UpdateAsync(membership);
            }
        }

        public async Task<List<PttGroupDto>> GetAllGroups()
        {
            var groups = await _groupRepository.GetAll()
                .Where(g => g.IsActive)
                .Select(g => new PttGroupDto
                {
                    Id = g.Id,
                    Name = g.Name,
                    Description = g.Description,
                    CreatedByAdminId = g.CreatedByAdminId,
                    IsActive = g.IsActive,
                    CreationTime = g.CreationTime
                })
                .ToListAsync();

            return groups;
        }
    }

    // DTOs
    public class PttGroupDto
    {
        public long Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public long CreatedByAdminId { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreationTime { get; set; }
    }

    public class PttGroupMemberDto
    {
        public long Id { get; set; }
        public long PttGroupId { get; set; }
        public long UserId { get; set; }
        public string UserName { get; set; }
        public string Name { get; set; }
        public string Surname { get; set; }
        public bool IsActive { get; set; }
        public DateTime JoinedDate { get; set; }
    }

    public class CreatePttGroupInput
    {
        public string Name { get; set; }
        public string Description { get; set; }
    }

    public class AddUserToGroupInput
    {
        public long GroupId { get; set; }
        public long UserId { get; set; }
    }

    public class RemoveUserFromGroupInput
    {
        public long GroupId { get; set; }
        public long UserId { get; set; }
    }
}

// Entity Classes
namespace Business.Solutions.PTT
{
    using System;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using Abp.Domain.Entities.Auditing;

    [Table("PttGroups")]
    public class PttGroup : FullAuditedEntity<long>
    {
        [Required]
        [MaxLength(128)]
        public string Name { get; set; }

        [MaxLength(500)]
        public string Description { get; set; }

        public long CreatedByAdminId { get; set; }

        public bool IsActive { get; set; }
    }

    [Table("PttGroupMembers")]
    public class PttGroupMember : FullAuditedEntity<long>
    {
        public long PttGroupId { get; set; }

        [ForeignKey("PttGroupId")]
        public virtual PttGroup PttGroup { get; set; }

        public long UserId { get; set; }

        public bool IsActive { get; set; }

        public DateTime JoinedDate { get; set; }
    }
}
