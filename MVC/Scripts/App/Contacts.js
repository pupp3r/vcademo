// email validation regex
function isEmail(email) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
}

// custom function for validating email fields
function validateEmail(inputElement, submitBtn) {
    $(inputElement).off("input");
    $(inputElement).on("input", function () {
        var value = $(this).val();
        if (isEmail(value) || value.length == 0) {
            $(this).parent().find("small[name=inputwarning]").remove();
            $(submitBtn).prop("disabled", false);
        } else {
            if ($(this).parent().find("small[name=inputwarning]").length == 0) {
                $(this).parent().append(`<small name="inputwarning" class="text-danger">Invalid email</span>`);
                $(submitBtn).prop("disabled", true);
            }
        }
    });
}

// phone validation regex 
function isPhone(phone) {
    var regex = /^((\+[1-9]{1,4}[ \-]*)|(\([0-9]{2,3}\)[ \-]*)|([0-9]{2,4})[ \-]*)*?[0-9]{3,4}?[ \-]*[0-9]{3,4}?$/;
    return regex.test(phone);
}

// custom phone validation function
function validatePhone(inputElement, submitBtn) {
    $(inputElement).off("input");
    $(inputElement).on("input", function () {
        var value = $(this).val();
        if (isPhone(value) || value.length == 0) {
            $(this).parent().find("small[name=inputwarning]").remove();
            $(submitBtn).prop("disabled", false);
        } else {
            if ($(this).parent().find("small[name=inputwarning]").length == 0) {
                $(this).parent().append(`<small name="inputwarning" class="text-danger">Invalid phone number</span>`);
                $(submitBtn).prop("disabled", true);
            }
        }
    });
}


function openAddModal() {
    // add validation before opening
    validateEmail("#addContactEmail", "#addSubmitBtn");
    validatePhone("#addContactPhone", "#addSubmitBtn");
    $("#addContactModal").modal("show");
}

function addContact() {
    // gather form data
    var firstName = $("#addContactFirstName").val();
    var lastName = $("#addContactLastName").val();
    var email = $("#addContactEmail").val();
    var phone = $("#addContactPhone").val();

    // send to server
    $.ajax({
        url: '/VCA_Contact_Demo/Contacts/AddContact',
        type: 'POST',
        data: {
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone
        },
        dataType: 'json',
        success: function (data) {
            if (data.success) {
                // contact successfully added
                toastr.success("Contact added");
                $("#addContactModal").modal("hide");
                clearForm("#addContactForm"); // clear the values before we open it again
                refreshTable(); // reflect changes in the page
            } else {
                // error returned in JSON
                toastr.error("Add Contact Failed (" + data.error + ")");
            }
        },
        error: function (request, error) {
            // request error
            toastr.error("Add Contact request failed");
            console.log("Request failed: " + JSON.stringify(request));
        }
    });
}



function openEditModal(sourceBtn) {
    var table = $("#contactsTable").DataTable();
    // grab the record's data from the row
    var row = table.row($(sourceBtn).closest("tr")[0]).data();
    // pre-populate the inputs on the edit form
    $("#editContactID").val(row.id);
    $("#editContactFirstName").val(row.firstname);
    $("#editContactLastName").val(row.lastname);
    $("#editContactEmail").val(row.email);
    $("#editContactPhone").val(row.phone);

    // add validation before opening
    validateEmail("#editContactEmail", "#editSubmitBtn");
    validatePhone("#editContactPhone", "#editSubmitBtn");

    $("#editContactModal").modal("show");
}


function editContact() {
    // gather info from form
    var contactID = $("#editContactID").val();
    var firstName = $("#editContactFirstName").val();
    var lastName = $("#editContactLastName").val();
    var email = $("#editContactEmail").val();
    var phone = $("#editContactPhone").val();

    // send info to server endpoint
    $.ajax({
        url: '/VCA_Contact_Demo/Contacts/EditContact',
        type: 'POST',
        data: {
            contactID: contactID,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone
        },
        dataType: 'json',
        success: function (data) {
            if (data.success) {
                // contact successfully edited
                toastr.success("Contact edited");
                $("#editContactModal").modal("hide");
                clearForm("#editContactForm"); // clear the form just in case
                refreshTable(); // reflect changes without refreshing the page
            } else {
                // error returned in JSON
                toastr.error("Edit Contact Failed (" + data.error + ")");
            }
        },
        error: function (request, error) {
            // request error
            toastr.error("Edit Contact request failed");
            console.log("Request failed: " + JSON.stringify(request));
        }
    });
}

function openDeleteModal(sourceBtn) {
    // grab the record's data from the row
    var table = $("#contactsTable").DataTable();
    var row = table.row($(sourceBtn).closest("tr")[0]).data();

    // set the text in the modal with our contact's name
    $("#deleteContactInfo").html("You are about to delete <b>" + row.firstname + " " + row.lastname + "</b><br/>Do you want to continue?");

    // remove any existing onclick from the confirm button
    $("#deleteContactConfirmButton").off("click");
    // add our delete function call to the confirm button
    $("#deleteContactConfirmButton").on("click", function () {
        deleteContact(row.id);
    })

    $("#deleteContactModal").modal("show");
}

function deleteContact(contactID) {
    // send info to server endpoint
    $.ajax({
        url: '/VCA_Contact_Demo/Contacts/DeleteContact',
        type: 'POST',
        data: {
            contactID: contactID
        },
        dataType: 'json',
        success: function (data) {
            if (data.success) {
                // contact successfully edited
                toastr.success("Contact deleted");
                $("#deleteContactModal").modal("hide");
                refreshTable(); // refresh the table to get rid of our deleted record
            } else {
                // error returned in JSON
                toastr.error("Delete Contact Failed (" + data.error + ")");
            }
        },
        error: function (request, error) {
            // request error
            toastr.error("Delete Contact request failed");
            console.log("Request failed: " + JSON.stringify(request));
        }
    });
}