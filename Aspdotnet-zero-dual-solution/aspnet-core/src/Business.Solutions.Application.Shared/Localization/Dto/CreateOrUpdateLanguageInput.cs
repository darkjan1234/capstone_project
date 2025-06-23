using System.ComponentModel.DataAnnotations;

namespace Business.Solutions.Localization.Dto
{
    public class CreateOrUpdateLanguageInput
    {
        [Required]
        public ApplicationLanguageEditDto Language { get; set; }
    }
}