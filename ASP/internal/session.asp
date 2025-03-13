<%
  'we have to call the javascript from inside < % % > tags because of the script execution order:
  ' 1. <script runat="server" language="not default language">
  ' 2. < % % >
  ' 3. <script runat="server" language="same as default language">
  ' If the javascript were to run first, the session variables set by the includes won't have happened yet!
  run
%>

<script language="javascript" runat="server" src='json2.js'></script>
<script language="javascript" runat="server">
/*  
    This page is for ASP.NET on same server to read and update the classic ASP session state while we have them running side by side.
    Inspiration for this technique from: https://gist.github.com/ktownsend-personal/f5097181c7fda9189be143b5feca18ac

    NOTE: It is critical that the REMOTE_ADDR vs. LOCAL_ADDR comparison works as intended to ensure only the server can call this page.
    NOTE: I had to update IIS to allow the custom MERGE, REPLACE, CLEAR and ABANDON request methods: 
           => Open IIS => Open Handler Mappings => Select "ASPClassic" => Request Restrictions => Verbs => select "All verbs", or add the ones you want to the list of accepted verbs.
           => Alternatively, you can configure this in web.config (<configuration> => <system.webServer> => <handlers>) with a <remove name="ASPClassic"> and an <add> to put it back in.
           => If that doesn't work, try also removing WebDav because I saw mention that can interfere (PUT and DELETE were mentioned).
    NOTE: In JScript, the Request.ServerVariables collection returns an object with Count and Item properties (Item is default property, but that only works in VBScript)

    We need json2.js because server-side JScript is very old and doesn't have the JSON object built-in like modern browsers do. 
    NOTE: If using JSON.parse() in VBScript, be aware that arrays are JScript arrays and you need dot syntax to access them (e.g., parsedObj.[0]).
    SOURCE: https://github.com/douglascrockford/JSON-js/blob/master/json2.js 
*/

  function run(){
    // IMPORTANT: it is critical that the remote and local address is the same to avoid external hacking
    if(Request.ServerVariables("REMOTE_ADDR").item === Request.ServerVariables("LOCAL_ADDR").item){

      switch(Request.ServerVariables("REQUEST_METHOD").item.toUpperCase()){
        case "GET":
          //provide session data to caller 
          //NOTE: Session property is reflected back with changes; other properties, like Debug, are safe to send anything you want without contaminating the session.
          var wrapper = {
            // ServerVariables: CollectionToObject(Request.ServerVariables, function(i){return i.Item}), //"default" property to get value from a Request.ServerVariables object is .Item
            Session: CollectionToObject(Session.Contents), //no default property to worry about on session items
            SessionId: Session.SessionId
          }
          Response.Clear();
          Response.ContentType = "application/json";
          Response.Write(JSON.stringify(wrapper, null, 2));
          break;
        case "MERGE":
          //merge JSON with existing session data
          SetSessionFromBodyJSON();
          break;
        case "REPLACE":
          //replace existing session data with JSON
          Session.Contents.RemoveAll();
          SetSessionFromBodyJSON();
          break;
        case "CLEAR":
          //clear session, but keep it alive
          Session.Contents.RemoveAll();
          break;
        case "ABANDON":
          //kill session
          Session.Contents.RemoveAll(); //this should be redundant, but it doesn't hurt
          Session.Abandon();
          break;
      }
    }
  }

  //enumerating COM collections is a PITA, so I made a function to push the items to an object
  function CollectionToObject(collection, mapper, target){
    var map = target ? target : {}; //fresh object if no target given to mutate
    for(var objEnum = new Enumerator(collection); !objEnum.atEnd(); objEnum.moveNext()){
      var key = objEnum.item();
      var val = collection(key);
      //try to handle VBScript arrays
      if (typeof(val) === 'unknown')
        try {
          val = (new VBArray(val)).toArray();
        } catch(e) {
          val = "{unknown type}";
        }
      //mapper callback gives caller a way to access a property to get the value if needed (looking at you Request.ServerVariables("key").Item)
      var mapped = typeof mapper === "function" ? mapper(val) : val;
      if(mapped !== undefined) map[key] = mapped;
    }
    return map;
  }

  function SetSessionFromBodyJSON(){
    var data = BodyJSONAsObject();
    if(!data) return;
    for(key in data)
      Session.Contents(key) = data[key];
  }

  function BodyJSONAsObject(){
    if(Request.TotalBytes > 0){
      var lngBytesCount = Request.TotalBytes;
      if(lngBytesCount > 100000) return null; //simple sanity check for length; come back to this if having truncation issues
      var data = BytesToStr(Request.BinaryRead(lngBytesCount));
      return JSON.parse(data);
    }
  }

  //used for getting string from request body; found here: https://stackoverflow.com/a/9777124
  function BytesToStr(bytes){
      var stream = Server.CreateObject("Adodb.Stream")
      stream.type = 1 //adTypeBinary
      stream.open
      stream.write(bytes)
      stream.position = 0
      stream.type = 2 //adTypeText
      stream.charset = "utf-8"
      var sOut = stream.readtext()
      stream.close
      return sOut
  }
</script>