using Abp.Application.Services.Dto;
using System;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetAllPttUsersForExcelInput
    {
        public string Filter { get; set; }

        public string FullNameFilter { get; set; }

        public string EmailFilter { get; set; }

        public string PasswordHashFilter { get; set; }

        public string RoleFilter { get; set; }

        public int? StatusFilter { get; set; }

    }
}