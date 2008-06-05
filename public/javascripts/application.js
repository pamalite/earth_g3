// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var e_timerRunning = false
var e_timerID = null
var e_delay = 3000

function initialize_polling(e_seconds)
{
  // Set the length of the timer, in seconds
  e_secs = e_seconds
  stopTheClock()
  startTheTimer()
}

function stopTheClock()
{
  e_secs = 0
  if(e_timerRunning)
    clearTimeout(e_timerID)
  e_timerRunning = false
}

function startTheTimer()
{
  if (e_secs==0)
  {
    stopTheClock()
    new Ajax.Request('/servers/statusdaemon', {method: 'post'});
  }
  else
  {
    e_secs = e_secs - 1
    e_timerRunning = true
    e_timerID = self.setTimeout("startTheTimer()", e_delay)
  }
}

