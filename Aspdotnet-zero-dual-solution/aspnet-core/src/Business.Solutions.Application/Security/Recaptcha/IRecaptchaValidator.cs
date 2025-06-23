using System.Threading.Tasks;

namespace Business.Solutions.Security.Recaptcha
{
    public interface IRecaptchaValidator
    {
        Task ValidateAsync(string captchaResponse);
    }
}