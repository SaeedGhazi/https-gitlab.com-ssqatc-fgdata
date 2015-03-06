define([
        'jquery', 'knockout', 'text!./metar.html' 
], function(jquery, ko, htmlString) {

    function ViewModel(params) {
      var NO_METAR = "no METAR";
      self.scrolledMetar = ko.observable("");
      self.textStart = 0;
      self.metar = ko.observable(NO_METAR);
      self.valid = ko.observable(false).extend({ fgprop: 'metar-valid' });
      self.valid.subscribe(function(newValue) {
        self.textStart = 0;
        if( false == newValue ) {
          self.metar(NO_METAR);
          return;
        }
        self.metar("Wait..");
        jquery.get('/json/environment/metar/data', null, function(data) {
          self.textStart = 0;
          self.metar(data.value);
        });
      });

      self.textLength = 20;
      self.timerId = 0;
      self.longTimeout = 1500;
      self.shortTimeout = 50;

      function scrollText ( id ){
          if( id != self.timerId )
              return;

          var t = self.metar() + " " + self.metar();
          var a = self.textStart;
          var b = a+self.textLength;
          self.scrolledMetar( t.substring(a,b) );
          var timeout = t.charAt(a) == ' ' ? self.longTimeout : self.shortTimeout;
          if( ++a  >= self.metar().length )
            a = 0;
          self.textStart = a;
          setTimeout(function() { scrollText(id); }, timeout );
      }

      scrollText( ++self.timerId );
    }

    ViewModel.prototype.dispose = function() {
      self.timerId++;
    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
