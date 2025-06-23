using Abp.Application.Services.Dto;
using System;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetAllLogsForExcelInput
    {
        public string Filter { get; set; }

        public int? MaxUserIdFilter { get; set; }
        public int? MinUserIdFilter { get; set; }

        public string ActivityFilter { get; set; }

        public string LogLevelFilter { get; set; }

    }
}