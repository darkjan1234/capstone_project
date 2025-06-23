using Microsoft.AspNetCore.Mvc;
using Business.Solutions.Web.Controllers;

namespace Business.Solutions.Web.Public.Controllers
{
    public class AboutController : SolutionsControllerBase
    {
        public ActionResult Index()
        {
            return View();
        }
    }
}