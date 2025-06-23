using System.Collections.Generic;
using Business.Solutions.Authorization.Users.Importing.Dto;
using Abp.Dependency;

namespace Business.Solutions.Authorization.Users.Importing
{
    public interface IUserListExcelDataReader: ITransientDependency
    {
        List<ImportUserDto> GetUsersFromExcel(byte[] fileBytes);
    }
}
