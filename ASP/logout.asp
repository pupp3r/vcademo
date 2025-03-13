<%
		Session.Contents.RemoveAll()
		Session.Abandon()
		Response.redirect("/?loggedOut=1")
%>