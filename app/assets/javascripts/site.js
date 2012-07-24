$(function() {
  $("#signup_form").bind("ajaxSend", function() {
    $("#signup_button").attr("disabled", "disabled");
    $("#loading").show();
  }).bind("ajaxComplete", function() {
    $("#signup_button").removeAattr("disabled");
    $("#loading").hide();
  });
});
