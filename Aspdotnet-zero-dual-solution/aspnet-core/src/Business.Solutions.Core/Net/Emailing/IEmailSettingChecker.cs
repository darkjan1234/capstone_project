using System.Threading.Tasks;

namespace Business.Solutions.Net.Emailing
{
    public interface IEmailSettingsChecker
    {
        bool EmailSettingsValid();

        Task<bool> EmailSettingsValidAsync();
    }
}