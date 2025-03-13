using Newtonsoft.Json;
using VCA_Contact_Demo.Extensions;
using System;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Mvc;

namespace VCA_Contact_Demo.ClassicASP
{
    public class SessionSyncFilter : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            base.OnActionExecuting(filterContext);

            //fetch classic ASP session state from the ASP engine running on same website
            string json = null;
            SyncClassicASP(filterContext.HttpContext, w => json = w.DownloadString(""));
            var data = JsonConvert.DeserializeObject<SessionInfo>(json);
            filterContext.Controller.ViewBag.ClassicASP = data;

            // User is required to be logged in on all ASP.NET MVC pages.
            if (String.IsNullOrEmpty(Convert.ToString(data["loggedin"])))
            {
                // if they are not, redirect them back to the asp login page
                filterContext.Result = new RedirectResult("/login.asp?loginRequired=1");
            }
        }

        public override void OnResultExecuted(ResultExecutedContext filterContext)
        {
            base.OnResultExecuted(filterContext);

            //push changed state back to classic ASP
            var classicASP = filterContext.Controller.ViewBag.ClassicASP as SessionInfo;
            if (classicASP == null || classicASP.SaveMode == SyncMode.ReadOnly) return; //nothing to push
            var json = JsonConvert.SerializeObject(classicASP.Session);
            var method = classicASP.SaveMode.ToString().ToUpper();
            SyncClassicASP(filterContext.HttpContext, w => w.UploadString("", method, json));
        }

        private void SyncClassicASP(HttpContextBase context, Action<WebClient> action)
        {
            //figure out the classic ASP session cookies (there can be multiple, so send them all)
            var aspcookies = context.Request.Cookies.AllKeys.Where(c => c.StartsWith("ASPSESSION"));
            var cookie = aspcookies.Count() > 0 ? string.Join("; ", aspcookies.Select(c => $"{c}={context.Request.Cookies[c].Value}").ToArray()) : null;

            //build URL for the request (same server)
            var uri = context.Request.Url;
            var url = $"{uri.Scheme}://{uri.Host}:{uri.Port}/internal/session.asp";

            //prepare WebClient with common settings
            var localIP = IPAddress.Parse(context.Request.ServerVariables["LOCAL_ADDR"]);
            using (var webClient = new WebClient())
            {
                //prepare common settings
                webClient.Headers[HttpRequestHeader.ContentType] = "application/json";
                if (cookie != null) webClient.Headers.Add(HttpRequestHeader.Cookie, cookie);
                webClient.Encoding = Encoding.UTF8;
                webClient.BaseAddress = url;

                //caller can do what they want with it
                action(webClient);

                //forward any new cookies to our response to "keep" the new session if one was created during the request
                webClient.ResponseHeaders?.GetValues("Set-Cookie")?.ToList().ForEach(c => context.Response.AddHeader("Set-Cookie", c));
            }
        }

    }
}