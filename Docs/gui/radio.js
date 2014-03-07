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

  // convert a JSON node to a PropertyNode by adding 
  // the API Methods
  makeNode: function( node ) {
    if( typeof(node) == 'undefined' ) return node; // not an object
    if( typeof(node.getNode) == 'function' ) return node; // allready done

    node.getNode = function( name ) {
      var reply;
      $.each( node.children, function( key, child ) {
        if( child.name == name ) {
          reply = props.makeNode( child );
        }
      });
      return reply;
    }
    return node;
  }
}

var reloadProperties = function() {
	 props.load( "instrumentation/comm?d=3", function(props) {
		  $("#com1u").val( props.getNode("comm").getNode("frequencies").getNode("selected-mhz-fmt").value );	
		  $("#com1s").val( props.getNode("comm").getNode("frequencies").getNode("standby-mhz-fmt").value );	
		  $("#com2u").val( props.getNode("comm[1]").getNode("frequencies").getNode("selected-mhz-fmt").value );	
		  $("#com1s").val( props.getNode("comm[1]").getNode("frequencies").getNode("standby-mhz-fmt").value );	
		  $("#nav1u").val( props.getNode("nav").getNode("frequencies").getNode("selected-mhz-fmt").value );	
		  $("#nav1s").val( props.getNode("nav").getNode("frequencies").getNode("standby-mhz-fmt").value );	
		  $("#nav1rad").val( props.getNode("nav").getNode("selected-deg").value );	
		  $("#nav2u").val( props.getNode("nav[1]").getNode("frequencies").getNode("selected-mhz-fmt").value );	
		  $("#nav2s").val( props.getNode("nav[1]").getNode("frequencies").getNode("standby-mhz-fmt").value );	
		  $("#nav2rad").val( props.getNode("nav[1]").getNode("selected-deg").value );	
		  $("#adf1u").val( props.getNode("adf").getNode("frequencies").getNode("selected-khz").value );	
		  $("#adf1s").val( props.getNode("adf").getNode("frequencies").getNode("standby-khz").value );	
		  $("#adf1rad").val( props.getNode("adf").getNode("rotation-deg").value );	
		  $("#dme1u").val( props.getNode("dme").getNode("frequencies").getNode("selected-mhz").value );	
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
 
