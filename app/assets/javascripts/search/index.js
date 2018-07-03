var Search = (function( $ ) {
  // custom suggester widget
  $.widget('custom.suggester', $.ui.autocomplete, {
    _renderMenu: function( ul, items ) {
      $.each( items, function( index, item ) {
        var category = $("<li class='ui-autocomplete-category'>" + item.label + "</li>")
                         .data('ui-autocomplete-item', {}) // TODO: add category url here...
        ul.append(category);

        $.each( item.value, function( index, value ) {
          var li = $(
            '<li class="ui-autocomplete-item">' +
              '<a href="/' + value.url +'">' +
                value.text +
              '</a>' +
            '</li>'
          ).data('ui-autocomplete-item', value );

          ul.append(li);
        })
      });
    }
  });

  var init = function () {
    $('#q').suggester({
      source: function( request, response ) {
        $.getJSON('/suggest', request)
        .done(function ( data ) {
          response(data);
        });
      }
    });
  }

  return {
    init: init
  }
})(jQuery);
