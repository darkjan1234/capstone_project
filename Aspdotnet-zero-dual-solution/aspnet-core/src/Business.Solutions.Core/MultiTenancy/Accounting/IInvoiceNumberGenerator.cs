using System.Threading.Tasks;
using Abp.Dependency;

namespace Business.Solutions.MultiTenancy.Accounting
{
    public interface IInvoiceNumberGenerator : ITransientDependency
    {
        Task<string> GetNewInvoiceNumber();
    }
}