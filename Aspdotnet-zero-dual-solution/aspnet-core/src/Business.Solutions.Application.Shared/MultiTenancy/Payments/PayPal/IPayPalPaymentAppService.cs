using System.Threading.Tasks;
using Abp.Application.Services;
using Business.Solutions.MultiTenancy.Payments.PayPal.Dto;

namespace Business.Solutions.MultiTenancy.Payments.PayPal
{
    public interface IPayPalPaymentAppService : IApplicationService
    {
        Task ConfirmPayment(long paymentId, string paypalOrderId);

        PayPalConfigurationDto GetConfiguration();
    }
}
