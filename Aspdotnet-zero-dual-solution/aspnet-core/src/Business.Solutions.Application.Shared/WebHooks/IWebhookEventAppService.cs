using System.Threading.Tasks;
using Abp.Webhooks;

namespace Business.Solutions.WebHooks
{
    public interface IWebhookEventAppService
    {
        Task<WebhookEvent> Get(string id);
    }
}
