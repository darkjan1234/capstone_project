using Abp.AutoMapper;
using Business.Solutions.Authorization.Users.Dto;

namespace Business.Solutions.Mobile.MAUI.Models.User
{
    [AutoMapFrom(typeof(CreateOrUpdateUserInput))]
    public class UserCreateOrUpdateModel : CreateOrUpdateUserInput
    {

    }
}
