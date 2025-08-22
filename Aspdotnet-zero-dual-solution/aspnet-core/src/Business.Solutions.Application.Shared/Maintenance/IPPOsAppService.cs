using System;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Business.Solutions.Maintenance.Dtos;
using Business.Solutions.Dto;

namespace Business.Solutions.Maintenance
{
    public interface IPPOsAppService : IApplicationService
    {
        Task<PagedResultDto<GetPPOForViewDto>> GetAll(GetAllPPOsInput input);

        Task<GetPPOForViewDto> GetPPOForView(Guid id);

        Task<GetPPOForEditOutput> GetPPOForEdit(EntityDto<Guid> input);

        Task CreateOrEdit(CreateOrEditPPODto input);

        Task Delete(EntityDto<Guid> input);

        Task<FileDto> GetPPOsToExcel(GetAllPPOsForExcelInput input);

    }
}