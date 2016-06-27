# Description
# Generic hubot script boilerplate
#
# Commands:
#   hubot script (me) <thing>
#
# Configuration:
# HUBOT_TWSS_PROB (optional)
#   if twss.prob evaluates to a probability above this, it will
#   respond with 'twss'.  Defaults to 0.98
#
#
# Author:
#   https://github.com/aaronstaves/

module.exports = (robot) ->

  #
  # listens to script or script me
  #
  twss = require 'twss'

  twssCooldownInterval = 15 * 60 * 1000 #15 minutes in milliseconds
  
  robot.hear /(.*)/i, (msg) ->

    string = msg.match[0];
    prob = process.env.HUBOT_TWSS_PROB or 0.9991
    
    console.log twss.prob string
    
    lastSnap = robot.brain.data.lastTwssSnap
    snappable = !lastSnap

    if (lastSnap)
        lastSnapMilliseconds = new Date(lastSnap).getTime()
        rightNowMilliseconds = new Date().getTime()
        snappable = (rightNowMilliseconds - lastSnapMilliseconds) > twssCooldownInterval
        
    if ( twss.prob string ) >= prob && snappable
        robot.brain.data.lastTwssSnap = new Date
        msg.send(':snap:')

  robot.respond /:snap:/, (res) ->
    lastSnap = robot.brain.data.lastTwssSnap
    if (lastSnap)
        lastSnapMilliseconds = new Date(lastSnap).getTime()
        rightNowMilliseconds = new Date().getTime()
        if (rightNowMilliseconds - lastSnapMilliseconds) < twssCooldownInterval
          remainingTime = lastSnapMilliseconds + twssCooldownInterval 
          futureTime = new Date().getTime() + remainingTime
          formattedTime = new Date(remainingTime)
          res.reply "next snap is at " + formattedTime.toString() 
        else
          res.reply "ready to snap!"
    else   
      res.reply "ready to snap!"
