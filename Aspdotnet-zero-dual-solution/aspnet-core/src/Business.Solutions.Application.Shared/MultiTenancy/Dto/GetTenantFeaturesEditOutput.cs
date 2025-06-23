using System.Collections.Generic;
using Abp.Application.Services.Dto;
using Business.Solutions.Editions.Dto;

namespace Business.Solutions.MultiTenancy.Dto
{
    public class GetTenantFeaturesEditOutput
    {
        public List<NameValueDto> FeatureValues { get; set; }

        public List<FlatFeatureDto> Features { get; set; }
    }
}