<!-- #include file="master.asp" -->

<%
	if Session("loggedin") <> "1" then
		Response.Redirect("/login.asp?loginRequired=1")
	end if
%>

<%

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then

Dim con
Dim comm
Dim username 
Dim password

' collect form data
username = Session("username")
password = Request.form("password")
oldpassword = Request.form("oldpassword")

' create connection object
Set con = Server.createObject("ADODB.connection")
' open connection with DSN (you will have to create this before deploying)
con.ConnectionString = Application("connectionString")
con.open

' create command object
Set comm = Server.createObject("ADODB.Command")
comm.ActiveConnection = con
comm.commandType = adCmdText
comm.Prepared = true


' check if user already exists
comm.CommandText = "select [username], [password] from webuser where username=? and password=?"
comm.Parameters.Append(comm.CreateParameter(, adVarChar, adParamInput, 250, username))
comm.Parameters.Append(comm.CreateParameter(, adVarChar, adParamInput, 250, oldpassword))

set rs = comm.execute

if rs.EOF = true then
	Response.write("Old password is incorrect")
	Response.end()
end if


' re-create command object
Set comm = Server.createObject("ADODB.Command")
comm.ActiveConnection = con
comm.commandType = adCmdText
comm.Prepared = true

' insert the data into the webuser table
comm.CommandText = "update webuser set password=? where username=?"
comm.Parameters.Append(comm.CreateParameter(, adVarChar, adParamInput, 250, password))
comm.Parameters.Append(comm.CreateParameter(, adVarChar, adParamInput, 250, username))

comm.execute(adExecuteNoRecords)

con.close
Response.redirect("/login.asp?passwordReset=1")

End If

%>



<% Sub Title %> Create Account <% End Sub %>

<% Sub BodyContent %>

<div class="row justify-content-center mt-5">
	<div class="col-xl-4 col-lg-6 col-md-8">

		<h4>Reset Password</h4>
		<br/>

		<form method="post" action="resetpassword.asp">
		  <div class="mb-3">
		    <label for="value" class="form-label">Old Password</label>
		    <input type="password" class="form-control" id="oldpassword" name="oldpassword" autocomplete="off">
		  </div>
		  <div class="mb-3">
		    <label for="value" class="form-label">Password</label>
		    <input type="password" class="form-control" id="password" name="password" autocomplete="off">
		  </div>
		  <div class="mb-3">
		    <label for="value" class="form-label">Confirm Password</label>
		    <input type="password" class="form-control" id="confirmpassword" name="confirmpassword" autocomplete="off">
		    <div id="inputRequiredWarning" class="form-text text-danger" style="display:none;">Password cannot be empty</div>
		    <div id="passwordWarning" class="form-text text-danger" style="display:none;">Passwords do not match</div>
		    <div id="passwordSuccess" class="form-text text-success" style="display:none;">Passwords match</div>
		  </div>
		  <button id="submitButton" type="submit" class="btn btn-primary" disabled>Submit</button>
		</form>
		
	</div>
</div>

<script>
$("#password, #confirmpassword").on("input keyup change", function() {
	var password = $("#password").val();
	var confirm = $("#confirmpassword").val();
	if (password.trim() == "" && confirm.trim() == "") {
		// empty password
		$("#inputRequiredWarning").show();
		$("#passwordSuccess").hide();
		$("#passwordWarning").hide();
	}
	else if (password == confirm) {
		// passwords match
		$("#passwordSuccess").show();
		$("#passwordWarning").hide();
		$("#inputRequiredWarning").hide();
		$("#submitButton").prop("disabled", false);
	} else {
		// passwords do not match
		$("#passwordSuccess").hide();
		$("#passwordWarning").show();
		$("#inputRequiredWarning").hide();
		$("#submitButton").prop("disabled", true);
	}
});
</script>

<% End Sub %>