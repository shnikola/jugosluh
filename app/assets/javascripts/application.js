$(function() {
  $('a[data-popup]').on('click', function(e) {
    window.open($(this).attr('href'), "Play", 'height=550,width=850'); 
    e.preventDefault();
  });
  
  $("input.autosubmit, select.autosubmit").on("change", function() {
    $(this).parents("form").submit();
  });
  
  var audio = $(".player").get(0);
  var tracklist = [];
  var currentTrack = 0;
   
  $(".play-button").on("click", function() {
    if (tracklist.length > 0) {
      play(0);
    } else {
      $.ajax({
        url: $(this).attr('href'),
        success: function(data) {
          tracklist = data;
          initPlayer();
          play(0);
        }
      });
    }
    return false;
  });
  
  function initPlayer() {
    $(".player-container").show();
    $(".player-container .prev").on("click", function() {
      play(currentTrack - 1);
    });
    $(".player-container .next").on("click", function() {
      play(currentTrack + 1);
    });
    $(audio).on("ended", function() {
      if (currentTrack < tracklist.length - 1) {
        play(currentTrack + 1);
      }
    });
  }
  
  function play(track) {
    currentTrack = (track + tracklist.length) % tracklist.length;
    audio.src = tracklist[currentTrack].url;
    audio.load();
    audio.play();
    $(".player-container .title").text(tracklist[currentTrack].title)
  }
});
