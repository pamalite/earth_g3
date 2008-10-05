// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Purpose - Required for updating UI daemon configuration page.
// Version - unexported version
// Date    - 12 Jun 2008
function refreshNow()
{
  // Delay before refreshing to ensure
  // the shutdown sequence done.
	setTimeout( "refresh()", 1000 );
}
function refreshDelay()
{
  // Delay a little longer before refreshing
  // to ensure bootup sequence is done.
  setTimeout( "refresh()", 4000 )
}
function refresh()
{
	window.location.reload( true );
}
