<!-- #include file="master.asp" -->

<% Sub Title %> Home Page <% End Sub %>

<% Sub BodyContent %>


	<% If Request("loggedOut").Count > 0 then %>
	<div class="row justify-content-center mt-5">
		<div class="col-lg-6 col-md-8">
			<div class="alert alert-danger" role="alert">
			  You have logged out. Please log in again.
			</div>
		</div>
	</div>
	<% End If %>

	<% If Request("loggedIn").Count > 0 then %>
	<div class="row justify-content-center mt-5">
		<div class="col-lg-6 col-md-8">
			<div class="alert alert-success" role="alert">
			  You have logged in. You can now view your contacts with the button below.
			</div>
		</div>
	</div>
	<% End If %>


	<div class="row mt-5">
		<div class="col text-center">
			<h1>Welcome</h1>

			<% if Session("loggedin") = "1" then %>
				<small>Logged in as <%=Session("username")%></small>
			<% else %>
				<small>Please <a href="/login.asp">log in</a> or <a href="/createaccount.asp">create an account</a> to continue</small>
			<% end if %>

		</div>
	</div>

	<div class="row mt-5">
		<div class="col text-center">
			<a class="btn btn-primary" href="/VCA_Contact_Demo/Contacts">Contacts</a>
		</div>
	</div>

<% End Sub %>