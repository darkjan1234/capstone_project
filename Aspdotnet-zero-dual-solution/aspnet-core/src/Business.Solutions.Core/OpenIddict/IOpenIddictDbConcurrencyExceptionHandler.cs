using System.Threading.Tasks;
using Abp.Domain.Uow;

namespace Business.Solutions.OpenIddict
{
    public interface IOpenIddictDbConcurrencyExceptionHandler
    {
        Task HandleAsync(AbpDbConcurrencyException exception);
    }
}