$(function() {

  if ($(".album-page").length == 0) return;
  
  var audio = $(".player").get(0);
  var playerInitalized = false;
  var tracklist = $(audio).data("tracks");
  var currentTrack = 0;

  $(".play-button").on("click", function() {
    playerInitalized || initPlayer();
    play(0);
    return false;
  });

  function initPlayer() {
    for (var i = 0; i < tracklist.length; i++) {
      $(".player-container .playlist").append("<div class='track' data-track=" + i + ">" + tracklist[i].title + "</div>")
    }
    $(".player-container").show();
    $(".player-container .track").on("click", function() {
      play($(this).data("track"))
    });

    $(audio).on("ended", function() {
      if (currentTrack < tracklist.length - 1) {
        play(currentTrack + 1);
      }
    });

    // Open links in new tab while playing
    $(audio).on("playing", function() {
      $("a").attr("target", "_blank");
    });
    $(audio).on("ended", function() {
      $("a").removeAttr("target");
    });

    playerInitalized = true;
  }

  function play(track) {
    currentTrack = (track + tracklist.length) % tracklist.length;
    audio.src = tracklist[currentTrack].url;
    audio.load();
    audio.play();
    $(".player-container .track").removeClass("active").eq(currentTrack).addClass("active");
  }

});
