using System.Collections.Generic;
using Business.Solutions.Authorization.Users.Dto;
using Business.Solutions.Dto;

namespace Business.Solutions.Authorization.Users.Exporting
{
    public interface IUserListExcelExporter
    {
        FileDto ExportToFile(List<UserListDto> userListDtos);
    }
}