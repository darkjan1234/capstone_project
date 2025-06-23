using Business.Solutions.Core.Dependency;
using Business.Solutions.Mobile.MAUI.Services.UI;

namespace Business.Solutions.Mobile.MAUI.Shared
{
    public class SolutionsMainLayoutPageComponentBase : SolutionsComponentBase
    {
        protected PageHeaderService PageHeaderService { get; set; }

        protected DomManipulatorService DomManipulatorService { get; set; }

        public SolutionsMainLayoutPageComponentBase()
        {
            PageHeaderService = DependencyResolver.Resolve<PageHeaderService>();
            DomManipulatorService = DependencyResolver.Resolve<DomManipulatorService>();
        }

        protected async Task SetPageHeader(string title)
        {
            PageHeaderService.Title = title;
            PageHeaderService.ClearButton();
            await DomManipulatorService.ClearModalBackdrop(JS);
        }

        protected async Task SetPageHeader(string title, List<PageHeaderButton> buttons)
        {
            PageHeaderService.Title = title;
            PageHeaderService.SetButtons(buttons);
            await DomManipulatorService.ClearModalBackdrop(JS);
        }
    }
}
