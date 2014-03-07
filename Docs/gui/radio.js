var props = 
{
  load : function( path, callback, base ) {
    if( typeof(base) == 'undefined' ) base = "/json/";
    var reply;
    $.getJSON( base + path, function( data ) {
        callback( props.makeNode( data ) );
    });
  },

  save : function( node, url ) {
    alert( "can't save yet :-(" );
  },

  makeNode: function( node ) {
    if( typeof(node) == 'undefined' ) return node;
    node.getNode = function( name ) {
      var reply;
      $.each( node.children, function( key, child ) {
        if( child.name == name ) {
          reply = child;
        }
      });
      return reply;
    }
    return node;
  }
}

var reloadProperties = function() {
	 props.load( "instrumentation/comm/frequencies", function(props) {
		  $("#com1u").val( props.getNode("selected-mhz-fmt").value );	
		  $("#com1s").val( props.getNode("standby-mhz-fmt").value );	
	  });

	  props.load( "instrumentation/comm[1]/frequencies", function(props) {
		  $("#com2u").val( props.getNode("selected-mhz-fmt").value );	
		  $("#com2s").val( props.getNode("standby-mhz-fmt").value );	
	  });

	  props.load( "instrumentation/nav/frequencies", function(props) {
		  $("#nav1u").val( props.getNode("selected-mhz-fmt").value );	
		  $("#nav1s").val( props.getNode("standby-mhz-fmt").value );
	  });

	  props.load( "instrumentation/nav/radials", function(props) {
		  $("#nav1rad").val( props.getNode("selected-deg").value );	
	  });

	  props.load( "instrumentation/nav[1]/frequencies", function(props) {
		  $("#nav2u").val( props.getNode("selected-mhz-fmt").value );	
		  $("#nav2s").val( props.getNode("standby-mhz-fmt").value );	
	  });

	  props.load( "instrumentation/nav[1]/radials", function(props) {
		  $("#nav2rad").val( props.getNode("selected-deg").value );	
	  });

	  props.load( "instrumentation/adf/frequencies", function(props) {
		  $("#adf1u").val( props.getNode("selected-khz").value );	
		  $("#adf1s").val( props.getNode("standby-khz").value );	
	  });

	  props.load( "instrumentation/adf", function(props) {
		  $("#adf1rad").val( props.getNode("rotation-deg").value );	
	  });

	  props.load( "instrumentation/dme/frequencies", function(props) {
		  $("#dme1u").val( props.getNode("selected-mhz").value );	
	  });
	  
}

$( document ).ready(function() {
   
  $("#com1swap").click( function() {
	  var v = $("#com1u").val();
	  $("#com1u").val( $("#com1s").val() );
	  $("#com1s").val(v);
  });

  $("#com2swap").click( function() {
	  var v = $("#com2u").val();
	  $("#com2u").val( $("#com2s").val() );
	  $("#com2s").val(v);
  });

  $("#nav1swap").click( function() {
	  var v = $("#nav1u").val();
	  $("#nav1u").val( $("#nav1s").val() );
	  $("#nav1s").val(v);
  });

  $("#nav2swap").click( function() {
	  var v = $("#nav2u").val();
	  $("#nav2u").val( $("#nav2s").val() );
	  $("#nav2s").val(v);
  });

  $("#adf1swap").click( function() {
	  var v = $("#adf1u").val();
	  $("#adf1u").val( $("#adf1s").val() );
	  $("#adf1s").val(v);
  });
  reloadProperties();
  window.setInterval(reloadProperties, 5000 );
});
 