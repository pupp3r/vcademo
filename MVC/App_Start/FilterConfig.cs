using System.Web.Mvc;

namespace VCA_Contact_Demo
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new ClassicASP.SessionSyncFilter());
            //filters.Add(new HandleErrorAttribute());
        }
    }
}
