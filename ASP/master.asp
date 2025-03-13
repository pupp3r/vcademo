<!doctype html>

<html lang="en">

	<head>
		<meta charset="UTF-8"/>
		<meta name="viewport" content="width=device-width, initial-scale=1"/>

		<title><% Title() %> - VCA Demo</title>
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous"/>
		<link href="/static/css/site.css" rel="stylesheet"/>
	</head>



	<body>
		<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>

	    <nav class="navbar navbar-expand-sm navbar-toggleable-sm navbar-dark bg-dark">
	        <div class="container">
	            <a class="navbar-brand" href="/">VCA Demo</a>
	            <button type="button" class="navbar-toggler" data-bs-toggle="collapse" data-bs-target=".navbar-collapse" title="Toggle navigation" aria-controls="navbarSupportedContent"
	                    aria-expanded="false" aria-label="Toggle navigation">
	                <span class="navbar-toggler-icon"></span>
	            </button>
	            <div class="collapse navbar-collapse d-sm-inline-flex justify-content-between">
	                <ul class="navbar-nav flex-grow-1">
	                    <li><a class="nav-link" href="/">Home</a></li>
	                    <li><a class="nav-link" href="/VCA_Contact_Demo/Contacts">Contacts</a></li>

	                    <% If Session("loggedin") = "1" Then %>
	                    	<li class="ms-auto">
								<a class="nav-link" href="/resetpassword.asp">Reset Password</a>
							</li>
	                    	<li>
								<a class="nav-link" href="/logout.asp">Log Out (<% Response.Write(Session("username")) %>)</a>
							</li>
						<% Else %>
							<li class="ms-auto"><a class="nav-link" href="/login.asp">Log In</a></li>
						<% End If %>
	                    
	                </ul>
	            </div>
	        </div>
	    </nav>
	    <div class="container body-content">
	        <% BodyContent() %>
	    </div>
	</body>

</html>