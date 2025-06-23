using Abp.Application.Services.Dto;
using System;

namespace Business.Solutions.Maintenance.Dtos
{
    public class GetAllPTTMessagesForExcelInput
    {
        public string Filter { get; set; }

        public int? MaxSenderIdFilter { get; set; }
        public int? MinSenderIdFilter { get; set; }

        public int? MaxReceiverIdFilter { get; set; }
        public int? MinReceiverIdFilter { get; set; }

        public int? MaxGroupIdFilter { get; set; }
        public int? MinGroupIdFilter { get; set; }

        public string AudioPathFilter { get; set; }

        public int? MaxDurationSecondsFilter { get; set; }
        public int? MinDurationSecondsFilter { get; set; }

    }
}