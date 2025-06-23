using System.Threading.Tasks;
using Business.Solutions.Authorization.Users;

namespace Business.Solutions.WebHooks
{
    public interface IAppWebhookPublisher
    {
        Task PublishTestWebhook();
    }
}
