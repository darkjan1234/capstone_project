using Abp.Application.Services.Dto;
using System;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetAllNotificationsForExcelInput
    {
        public string Filter { get; set; }

        public int? MaxUserIdFilter { get; set; }
        public int? MinUserIdFilter { get; set; }

        public string MessageFilter { get; set; }

        public int? IsreadFilter { get; set; }

    }
}