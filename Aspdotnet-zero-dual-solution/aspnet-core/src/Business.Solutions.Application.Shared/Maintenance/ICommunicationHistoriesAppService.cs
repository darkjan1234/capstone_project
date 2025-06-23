using System;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;

namespace Business.Solutions.Maintenance
{
    public interface ICommunicationHistoriesAppService : IApplicationService
    {
        Task<PagedResultDto<GetCommunicationHistoryForViewDto>> GetAll(GetAllCommunicationHistoriesInput input);

        Task<GetCommunicationHistoryForViewDto> GetCommunicationHistoryForView(Guid id);

        Task<GetCommunicationHistoryForEditOutput> GetCommunicationHistoryForEdit(EntityDto<Guid> input);

        Task CreateOrEdit(CreateOrEditCommunicationHistoryDto input);

        Task Delete(EntityDto<Guid> input);

        Task<FileDto> GetCommunicationHistoriesToExcel(GetAllCommunicationHistoriesForExcelInput input);

    }
}