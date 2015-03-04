###
# Clock
#
# @cjsx React.DOM
###

React = require 'react'

# Extend "Number" to support "00" format
Number.prototype.padLeft = (length, padString) ->
  length ||= 1
  padString ||= "0"
  numberLength = @toString().length

  if length > numberLength
    return (new Array(length - numberLength + 1)).join(padString) + @toString()

  @toString()

module.exports = React.createClass {
  displayName: 'Clock'
  getInitialState: ->
    {
      remainTime: 0
      newHours: 0
      newMinutes: 0
      newSeconds: 0
    }

  getDefaultProps: ->
    {
      hours: 0
      minutes: 0
      seconds: 0
      isPause: false
    }

  _Tick: ->
    if @state.remainTime > 0
      remainTime = @state.remainTime - 1
      [hours, minutes, seconds] = @_SecondsToHuman(remainTime)

      @setState {
        remainTime: remainTime
        newHours: hours
        newMinutes: minutes
        newSeconds: seconds
      }

      @timer = setTimeout(@_Tick, 1000)
    else
      @props.onTimeout() if @props.onTimeout
      clearTimeout(@timer)

  _SecondsToHuman: (remainTime)->
    hours = Math.floor(remainTime / 3600)
    minutes = Math.floor( (remainTime % 3600) / 60 )
    seconds = (remainTime % 3600) % 60

    [hours, minutes, seconds]

  _Humanize: (usePad)->
    [@state.newHours.padLeft(2), @state.newMinutes.padLeft(2), @state.newSeconds.padLeft(2)]

  _onUpdateTime: (e) ->

    [hours, minutes, seconds] = [@state.newHours, @state.newMinutes, @state.newSeconds]

    switch e.target.name
      when "hours" then hours = Number(e.target.value) || 0
      when "minutes" then minutes = Number(e.target.value) || 0
      when "seconds" then seconds = Number(e.target.value) || 0

    countDownSeconds = hours * 3600 + minutes * 60 + seconds
    [hours, minutes, seconds] = @_SecondsToHuman(countDownSeconds)

    @setState {
      remainTime: countDownSeconds
      newHours: hours
      newMinutes: minutes
      newSeconds: seconds
    }

  reset: ->
    @setState @getInitialState()

  componentWillMount: ->
    countDownSeconds = @props.hours * 3600 + @props.minutes * 60 + @props.seconds
    @setState {
      remainTime: countDownSeconds
    }

  componentDidMount: ->
    @timer = setTimeout(@_Tick, 1000)

  componentWillReceiveProps: (nextProps) ->
    clearTimeout(@timer)
    if !nextProps.isPause
      @timer = setTimeout(@_Tick, 1000)

  componentWillUnmont: ->
    clearTimeout(@timer)

  render: ->
    if @props.isPause
      [hours, minutes, seconds] = [@state.newHours.padLeft(2), @state.newMinutes.padLeft(2), @state.newSeconds.padLeft(2)]
    else
      [hours, minutes, seconds] = @_Humanize()

    (
      <div className="clock">
        <input tabIndex={1} className="clock-time" type="text" value={hours} name="hours" disabled={!@props.isPause} onChange={@_onUpdateTime} />
        <span className="clock-time split">:</span>
        <input tabIndex={2} className="clock-time" type="text" value={minutes} name="minutes" disabled={!@props.isPause} onChange={@_onUpdateTime} />
        <span className="clock-time split">:</span>
        <input tabIndex={3} className="clock-time" type="text" value={seconds} name="seconds" disabled={!@props.isPause} onChange={@_onUpdateTime} />
      </div>
    )
}