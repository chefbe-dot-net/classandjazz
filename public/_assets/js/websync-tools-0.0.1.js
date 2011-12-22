var websync = {
  tools: {
  
    external_links_to_blank: function() {
      $.expr[':'].external = function(obj){
          return !obj.href.match(/^mailto\:/)
                  && (obj.hostname != location.hostname);
      };
      $('a:external').attr('target', '_blank');
    },

    image_tooltips: function() {
      $("img[alt]").twipsy({title: "alt", placement: "right", offset: -100});
    }
  
  }
}
