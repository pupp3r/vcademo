<!-- #include file="master.asp" -->

<%
	If Request.ServerVariables("REQUEST_METHOD") = "POST" Then

		Dim con
		Dim comm
		Dim rs
		Dim username 
		Dim password

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

		' collect form data
		username = Request.form("username")
		password = Request.form("password")

		' check the provided credentials against the DB
		comm.CommandText = "select id, [username], [password] from webuser where username=?"
		comm.Parameters.Append(comm.CreateParameter(, adVarChar, adParamInput, 250, username))

		set rs = comm.execute

		if rs.EOF = false then
			Dim dbPass
			set dbPass = rs("password")
			if dbPass = password then
				Session.Contents.RemoveAll()
				Session("loggedin") = "1"
				Session("username") = username
				Session("webuserid") = rs("id")
				Response.redirect("/?loggedIn=1")
			end if
		end if

		Response.Write("Incorrect username/password")

	End If
%>


<% Sub Title %> Log In <% End Sub %>

<% Sub BodyContent %>

<% If Request("loginRequired").Count > 0 then %>
<div class="row justify-content-center mt-5">
	<div class="col-xl-4 col-lg-6 col-md-8">
		<div class="alert alert-danger" role="alert">
		  Please log in to continue
		</div>
	</div>
</div>
<% End If %>

<% If Request("accountCreated").Count > 0 then %>
<div class="row justify-content-center mt-5">
	<div class="col-xl-4 col-lg-6 col-md-8">
		<div class="alert alert-success" role="alert">
		  Account created. You can now log in.
		</div>
	</div>
</div>
<% End If %>

<% If Request("passwordReset").Count > 0 then %>
<div class="row justify-content-center mt-5">
	<div class="col-xl-4 col-lg-6 col-md-8">
		<div class="alert alert-success" role="alert">
		  Password successfully reset. You can now log in.
		</div>
	</div>
</div>
<% End If %>

<div class="row justify-content-center mt-5">
	<div class="col-xl-4 col-lg-6 col-md-8">

		<form method="post" action="login.asp">
		  <div class="mb-3">
		    <label for="name" class="form-label">Username</label>
		    <input type="text" class="form-control" id="username" name="username" autocomplete="off">
		  </div>
		  <div class="mb-3">
		    <label for="value" class="form-label">Password</label>
		    <input type="password" class="form-control" id="password" name="password" autocomplete="off">
		    <div id="emailHelp" class="form-text">No account? <a href="/createaccount.asp">Register Here</a></div>
		  </div>
		  <button type="submit" class="btn btn-primary">Submit</button>
		</form>
		
	</div>
</div>

<% End Sub %>