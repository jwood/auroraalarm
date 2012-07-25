$(function() {
  $("#signup_button").removeAttr("disabled");
  $("#signup_form").bind("ajaxSend", function() {
    $("#signup_button").attr("disabled", "disabled");
    $("#signup_form_content").css({ opacity: 0.1 });
    $("#loading").css({
      position: "absolute",
      top: $("#signup_form_content").position().top + (($("#signup_form_content").height() - $("#loading").height()) / 2),
      left: $("#signup_form_content").position().left + 150
    });
    $("#loading").show();
  }).bind("ajaxComplete", function() {
    $("#signup_button").removeAttr("disabled");
    $("#signup_form_content").css({ opacity: 1 });
    $("#loading").hide();
  });

  $('nav').localScroll({ duration:400 });
});
