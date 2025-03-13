function clearForm(formElement) {
    $(formElement).find("input").each(function () {
        $(this).val("");
    })
    $(formElement).find("small[name=inputwarning]").remove();
}