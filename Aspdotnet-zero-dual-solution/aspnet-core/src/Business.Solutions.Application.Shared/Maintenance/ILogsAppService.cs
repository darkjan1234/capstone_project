using System;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;

namespace Business.Solutions.Maintenance
{
    public interface ILogsAppService : IApplicationService
    {
        Task<PagedResultDto<GetLogForViewDto>> GetAll(GetAllLogsInput input);

        Task<GetLogForViewDto> GetLogForView(Guid id);

        Task<GetLogForEditOutput> GetLogForEdit(EntityDto<Guid> input);

        Task CreateOrEdit(CreateOrEditLogDto input);

        Task Delete(EntityDto<Guid> input);

        Task<FileDto> GetLogsToExcel(GetAllLogsForExcelInput input);

    }
}