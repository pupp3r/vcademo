using System.Web.Mvc;
using VCA_Contact_Demo.ClassicASP;

namespace VCA_Contact_Demo.Extensions
{
    public static class ControllerExtensions
    {
        public static SessionInfo ClassicASP(this Controller controller) =>
            controller.ViewBag.ClassicASP;
    }
}