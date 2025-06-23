using System;
using Abp.Application.Services.Dto;

namespace Business.Solutions.Maintenance.Dtos
{
    public class PttUserDto : EntityDto<Guid>
    {
        public string FullName { get; set; }

        public string Email { get; set; }

        public string PasswordHash { get; set; }

        public string Role { get; set; }

        public bool Status { get; set; }

    }
}