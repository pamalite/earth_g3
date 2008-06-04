// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var e_timerRunning = false
var e_timerID = null
var e_delay = 3000

function initialize_polling(e_seconds)
{
    // Set the length of the timer, in seconds
    e_secs = e_seconds
    example_StopTheClock()
    example_StartTheTimer()
}

function example_StopTheClock()
{
    e_secs = 0
    if(e_timerRunning)
        clearTimeout(e_timerID)
    e_timerRunning = false
}

function example_StartTheTimer()
{
    if (e_secs==0)
    {
        example_StopTheClock()
        new Ajax.Request('/servers/update_daemon_status', {
          method:     'post'
        });
    }
    else
    {
        e_secs = e_secs - 1
        e_timerRunning = true
        e_timerID = self.setTimeout("StartTheTimer()", e_delay)
    }
}

