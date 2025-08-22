using System.Collections.Generic;
using Abp.Runtime.Session;
using Abp.Timing.Timezone;
using Business.Solutions.DataExporting.Excel.MiniExcel;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;
using Business.Solutions.Storage;

namespace Business.Solutions.Maintenance.Exporting
{
    public class PPOsExcelExporter : MiniExcelExcelExporterBase, IPPOsExcelExporter
    {

        private readonly ITimeZoneConverter _timeZoneConverter;
        private readonly IAbpSession _abpSession;

        public PPOsExcelExporter(
            ITimeZoneConverter timeZoneConverter,
            IAbpSession abpSession,
            ITempFileCacheManager tempFileCacheManager) :
    base(tempFileCacheManager)
        {
            _timeZoneConverter = timeZoneConverter;
            _abpSession = abpSession;
        }

        public FileDto ExportToFile(List<GetPPOForViewDto> ppOs)
        {

            var items = new List<Dictionary<string, object>>();

            foreach (var ppo in ppOs)
            {
                items.Add(new Dictionary<string, object>()
                    {
                        {L("ProvincialName"), ppo.PPO.ProvincialName},
                        {L("isActive"), ppo.PPO.isActive},

                    });
            }

            return CreateExcelPackage("PPOsList.xlsx", items);

        }
    }
}