using System.Threading.Tasks;

namespace Business.Solutions.Net.Sms
{
    public interface ISmsSender
    {
        Task SendAsync(string number, string message);
    }
}