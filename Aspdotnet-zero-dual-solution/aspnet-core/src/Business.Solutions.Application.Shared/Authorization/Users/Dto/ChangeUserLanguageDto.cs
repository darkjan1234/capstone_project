using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Authorization.Users.Dto
{
    public class ChangeUserLanguageDto
    {
        [Required]
        public string LanguageName { get; set; }
    }
}
