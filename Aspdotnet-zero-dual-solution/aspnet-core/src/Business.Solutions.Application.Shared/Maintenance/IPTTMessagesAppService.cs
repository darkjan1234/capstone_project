using System;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;

namespace Business.Solutions.Maintenance
{
    public interface IPTTMessagesAppService : IApplicationService
    {
        Task<PagedResultDto<GetPTTMessageForViewDto>> GetAll(GetAllPTTMessagesInput input);

        Task<GetPTTMessageForViewDto> GetPTTMessageForView(Guid id);

        Task<GetPTTMessageForEditOutput> GetPTTMessageForEdit(EntityDto<Guid> input);

        Task CreateOrEdit(CreateOrEditPTTMessageDto input);

        Task Delete(EntityDto<Guid> input);

        Task<FileDto> GetPTTMessagesToExcel(GetAllPTTMessagesForExcelInput input);

    }
}