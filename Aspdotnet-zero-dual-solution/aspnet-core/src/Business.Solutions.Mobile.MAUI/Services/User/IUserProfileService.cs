namespace Business.Solutions.Mobile.MAUI.Services.User
{
    public interface IUserProfileService
    {
        Task<string> GetProfilePicture(long userId);

        string GetDefaultProfilePicture();
    }
}