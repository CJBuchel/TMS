
import React, { Component } from 'react'
import { Dropdown, Button, Icon } from 'semantic-ui-react'

import './index.css'

import startSound from './mp3/start.mp3'
import stopSound from './mp3/stop.mp3'
import endgameSound from './mp3/end-game.mp3'
import endSound from './mp3/end.mp3'

import { onStartEvent, onEndEvent, onStopEvent, onEndGameEvent } from '../mhub-listener'

export default class Sound extends Component {
  constructor (props) {
    super(props)

    this.startAudio = new window.Audio(startSound)
    this.stopAudio = new window.Audio(stopSound)
    this.endgameAudio = new window.Audio(endgameSound)
    this.endAudio = new window.Audio(endSound)

    window.localStorage.setItem('sound-window', true)

    window.onbeforeunload = function () {
      return 'Closing this window will stop the sounds of the timer. Are you sure you want to close it?'
    }

    window.onunload = () => {
      window.localStorage.removeItem('sound-window')
    }

    window.onstorage = event => {
      if (event.key === 'focus' && event.newValue) {
        window.focus()
        window.localStorage.removeItem('focus')
      }
    }

    onStartEvent(() => {
      this.playSoundIfEnabled(this.startAudio)
    })

    onEndGameEvent(() => {
      this.playSoundIfEnabled(this.endgameAudio)
    })

    onEndEvent(() => {
      this.playSoundIfEnabled(this.endAudio)
    })

    onStopEvent(() => {
      this.playSoundIfEnabled(this.stopAudio)
    })

    this.state = { enabled: true }
  }

  playSound (audio) {
    audio.play()
      .catch(err => {
        console.error(err)
      })
  }

  toggleState (isEnabled) {
    if (isEnabled) {
      this.setState({ enabled: false })
    } else {
      this.setState({ enabled: true })
    }
  }

  playSoundIfEnabled (sound) {
    if (this.state.enabled) {
      this.playSound(sound)
    }
  }

  render () {
    return <Button.Group className='settings show-on-hover'>
      <Dropdown floating labeled button icon='cogs' text='Test sounds' className='primary icon'>
        <Dropdown.Menu>
          <Dropdown.Item onClick={() => this.playSound(this.startAudio)}>Start match</Dropdown.Item>
          <Dropdown.Item onClick={() => this.playSound(this.endAudio)}>End match</Dropdown.Item>
          <Dropdown.Item onClick={() => this.playSound(this.stopAudio)}>Abort match</Dropdown.Item>
          <Dropdown.Item onClick={() => this.playSound(this.endgameAudio)}>30-sec warning</Dropdown.Item>
        </Dropdown.Menu>
      </Dropdown>
      <Button color={this.state.enabled ? 'orange' : ''} onClick={() => this.toggleState(this.state.enabled)}>
        <Icon name={`volume ${this.state.enabled ? 'up' : 'off'}`} />
        {this.state.enabled ? 'Sound on' : 'Sound off'}
      </Button>
    </Button.Group>
  }
}
