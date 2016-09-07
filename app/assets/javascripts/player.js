$(function() {

  if ($(".album-page").length == 0) return;

  var audio = $(".player").get(0);
  var playerInitalized = false;
  var tracklist = $(audio).data("tracks");
  var albumId = $(audio).data("album-id");
  var currentTrack = 0;

  initPlayer();

  function initPlayer() {
    for (var i = 0; i < tracklist.length; i++) {
      $(".player-container .playlist").append("<div class='track' data-track=" + i + ">" + tracklist[i].title + "</div>")
    }

    $(".player-container .track").on("click", function() {
      play($(this).data("track"));
    });

    $(".play-button").on("click", function() {
      play(0);
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

    // Save current time when closing window.
    $(window).on('unload', function() {
      if (!audio.paused) {
        localStorage.setItem("playing-album-" + albumId, currentTrack + ":" + audio.currentTime);
      }
    });

    var savedState = localStorage.getItem("playing-album-" + albumId);
    if (savedState) {
      localStorage.removeItem("playing-album-" + albumId);
      var state = savedState.split(":");
      play(+state[0], +state[1])
    }

    playerInitalized = true;
  }

  function play(track, seekTime) {
    currentTrack = (track + tracklist.length) % tracklist.length;
    audio.src = tracklist[currentTrack].url;
    audio.load();
    audio.play();
    if (seekTime) audio.currentTime = seekTime;
    $(".player-container").show();
    $(".player-container .track").removeClass("active").eq(currentTrack).addClass("active");
  }

});
