using System.Threading.Tasks;
using Abp.Application.Services.Dto;
using Business.Solutions.MultiTenancy.Accounting.Dto;

namespace Business.Solutions.MultiTenancy.Accounting
{
    public interface IInvoiceAppService
    {
        Task<InvoiceDto> GetInvoiceInfo(EntityDto<long> input);

        Task CreateInvoice(CreateInvoiceDto input);
    }
}
