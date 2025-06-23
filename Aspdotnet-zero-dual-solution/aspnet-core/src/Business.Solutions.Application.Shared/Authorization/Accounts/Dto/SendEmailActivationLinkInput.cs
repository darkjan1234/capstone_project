using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Authorization.Accounts.Dto
{
    public class SendEmailActivationLinkInput
    {
        [Required]
        public string EmailAddress { get; set; }
    }
}