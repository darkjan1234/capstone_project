using Abp.Events.Bus;

namespace Business.Solutions.MultiTenancy
{
    public class RecurringPaymentsEnabledEventData : EventData
    {
        public int TenantId { get; set; }
    }
}