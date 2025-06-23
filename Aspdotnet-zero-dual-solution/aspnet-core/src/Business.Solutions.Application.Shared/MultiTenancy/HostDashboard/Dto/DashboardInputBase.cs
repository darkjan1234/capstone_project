using System;

namespace Business.Solutions.MultiTenancy.HostDashboard.Dto
{
    public class DashboardInputBase
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
    }
}