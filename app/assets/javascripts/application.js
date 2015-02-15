//= require jquery
//= require jquery_ujs

$(function() {
  $('a[data-popup]').on('click', function(e) {
    console.log($(this).attr('href')) 
    window.open($(this).attr('href'), "Play", 'height=550,width=850'); 
    e.preventDefault();
  });
});