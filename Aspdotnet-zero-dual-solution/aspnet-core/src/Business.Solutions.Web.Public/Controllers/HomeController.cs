using Microsoft.AspNetCore.Mvc;
using Business.Solutions.Web.Controllers;

namespace Business.Solutions.Web.Public.Controllers
{
    public class HomeController : SolutionsControllerBase
    {
        public ActionResult Index()
        {
            return View();
        }
    }
}