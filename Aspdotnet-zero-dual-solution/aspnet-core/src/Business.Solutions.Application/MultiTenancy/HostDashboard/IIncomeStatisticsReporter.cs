using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Business.Solutions.MultiTenancy.HostDashboard.Dto;

namespace Business.Solutions.MultiTenancy.HostDashboard
{
    public interface IIncomeStatisticsService
    {
        Task<List<IncomeStastistic>> GetIncomeStatisticsData(DateTime startDate, DateTime endDate,
            ChartDateInterval dateInterval);
    }
}