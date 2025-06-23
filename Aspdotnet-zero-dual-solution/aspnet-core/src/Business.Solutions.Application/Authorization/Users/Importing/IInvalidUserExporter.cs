using System.Collections.Generic;
using Business.Solutions.Authorization.Users.Importing.Dto;
using Business.Solutions.Dto;

namespace Business.Solutions.Authorization.Users.Importing
{
    public interface IInvalidUserExporter
    {
        FileDto ExportToFile(List<ImportUserDto> userListDtos);
    }
}
