//= require jquery
//= require rails-ujs
//= require player
//= require radio

$(function() {
  $('a[data-popup]').on('click', function(e) {
    window.open($(this).attr('href'), "Play", 'height=550,width=850');
    e.preventDefault();
  });

  $("input.autosubmit, select.autosubmit").on("change", function() {
    $(this).parents("form").submit();
  });

  $("#list-selection").on("change", function() {
    $(".new-list").toggle(!$(this).val());
  }).trigger("change");

});
