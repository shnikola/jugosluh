$(function() {

  if ($(".radio-page").length == 0) return;

  var audio = $(".player").get(0);
  var track = null;

  initPlayer();
  loadNextTrack();

  function initPlayer() {
    $(".player-container .track").on("click", function() {
      audio.paused ? audio.play() : audio.pause();
    });

    $(".player-container .next-track").on("click", function() {
      loadNextTrack(true);
    });

    $(audio).on("ended", function() {
      loadNextTrack(true);
    });

    // Open links in new tab while playing
    $(audio).on("playing", function() {
      $("a").attr("target", "_blank");
    });
    $(audio).on("ended", function() {
      $("a").removeAttr("target");
    });
  }

  function loadNextTrack(play) {
    $.ajax({
      url: $(audio).data("next-track-url"),
      success: function(data) {
        $(".player-container .playlist .track").html(data.track.title)
        $(".player-container .album-image").attr("src", data.album.image_url);
        $(".player-container .album-title").html(data.album.artist + " - " + data.album.title);
        $(".player-container .info-link").attr("href", "/albums/" + data.album.id)
        audio.src = data.track.url;
        audio.load();
        play && audio.play();
      }
    });
  }

});
