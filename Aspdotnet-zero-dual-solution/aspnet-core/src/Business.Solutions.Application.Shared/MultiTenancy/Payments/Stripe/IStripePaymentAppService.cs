using System.Threading.Tasks;
using Abp.Application.Services;
using Business.Solutions.MultiTenancy.Payments.Dto;
using Business.Solutions.MultiTenancy.Payments.Stripe.Dto;

namespace Business.Solutions.MultiTenancy.Payments.Stripe
{
    public interface IStripePaymentAppService : IApplicationService
    {
        Task ConfirmPayment(StripeConfirmPaymentInput input);

        StripeConfigurationDto GetConfiguration();

        Task<SubscriptionPaymentDto> GetPaymentAsync(StripeGetPaymentInput input);

        Task<string> CreatePaymentSession(StripeCreatePaymentSessionInput input);
    }
}