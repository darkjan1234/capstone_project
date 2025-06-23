using Business.Solutions.Editions.Dto;

namespace Business.Solutions.MultiTenancy.Payments.Dto
{
    public class PaymentInfoDto
    {
        public EditionSelectDto Edition { get; set; }

        public decimal AdditionalPrice { get; set; }

        public bool IsLessThanMinimumUpgradePaymentAmount()
        {
            return AdditionalPrice < SolutionsConsts.MinimumUpgradePaymentAmount;
        }
    }
}
