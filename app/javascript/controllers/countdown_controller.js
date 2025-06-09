// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timer"]
  static values = {
    duration: Number,     // Duration in seconds
    autoAdvance: Boolean, // Whether to auto-advance when timer ends
    nextStage: Number,    // Next stage to advance to
    sessionUuid: String   // Session UUID for the advance URL
  }

  connect() {
    this.duration = this.durationValue
    this.isRunning = false
    this.isPaused = false

    console.log(`Countdown initialized: ${this.duration}s, auto-advance: ${this.autoAdvanceValue}`)

    // Start CSS animation timer
    this.start()
  }

  disconnect() {
    this.stop()
  }

  start() {
    if (this.isRunning) return

    this.isRunning = true
    console.log("Countdown started")

    // Apply the appropriate CSS class based on duration
    const timerElement = this.hasTimerTarget ? this.timerTarget : this.element
    const countdownClass = this.getCountdownClass()

    if (countdownClass) {
      timerElement.id = countdownClass
      timerElement.classList.add('countdown-active')
    }

    // Set timeout to handle completion
    this.timeoutId = setTimeout(() => {
      this.finish()
    }, this.duration * 1000)
  }

  stop() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
    this.isRunning = false

    // Remove animation classes
    const timerElement = this.hasTimerTarget ? this.timerTarget : this.element
    timerElement.classList.remove('countdown-active')
    timerElement.style.animationPlayState = 'running'

    console.log("Countdown stopped")
  }

  pause() {
    if (!this.isRunning || this.isPaused) return

    this.isPaused = true
    const timerElement = this.hasTimerTarget ? this.timerTarget : this.element
    timerElement.style.animationPlayState = 'paused'
    timerElement.classList.add('paused')

    console.log("Countdown paused")
  }

  resume() {
    if (!this.isRunning || !this.isPaused) return

    this.isPaused = false
    const timerElement = this.hasTimerTarget ? this.timerTarget : this.element
    timerElement.style.animationPlayState = 'running'
    timerElement.classList.remove('paused')

    console.log("Countdown resumed")
  }

  reset() {
    this.stop()

    // Reset the element
    const timerElement = this.hasTimerTarget ? this.timerTarget : this.element
    timerElement.classList.remove('finished', 'paused', 'countdown-active')
    timerElement.id = ''

    // Restart
    setTimeout(() => {
      this.start()
    }, 100)
  }

  finish() {
    this.stop()

    const timerElement = this.hasTimerTarget ? this.timerTarget : this.element
    timerElement.classList.add("finished")

    console.log("Countdown finished!")

    // Trigger auto-advance if enabled
    if (this.autoAdvanceValue && this.nextStageValue && this.sessionUuidValue) {
      this.advanceStage()
    }

    // Dispatch custom event
    this.dispatch("finished", {
      detail: {
        sessionUuid: this.sessionUuidValue,
        nextStage: this.nextStageValue
      }
    })
  }

  getCountdownClass() {
    // Map duration to existing CSS classes
    switch(this.duration) {
      case 5:
        return 'countdown-5'
      case 10:
        return 'countdown-10'
      case 15:
        return 'countdown-15'
      default:
        // For other durations, we'll need to create dynamic animations
        console.warn(`No predefined CSS animation for ${this.duration} seconds. Consider adding it to _timers.scss`)
        return this.createDynamicCountdown()
    }
  }

  createDynamicCountdown() {
    // Create a dynamic countdown ID for non-standard durations
    const dynamicId = `countdown-${this.duration}`

    // Check if we already created this animation
    if (!document.getElementById(`style-${dynamicId}`)) {
      this.injectDynamicCSS(dynamicId, this.duration)
    }

    return dynamicId
  }

  injectDynamicCSS(id, duration) {
    // Create dynamic CSS animation for custom durations
    let keyframes = '@keyframes count-' + duration + ' {\n'

    for (let i = 0; i <= duration; i++) {
      const percentage = (i / duration) * 100
      const number = duration - i
      keyframes += `  ${percentage.toFixed(1)}% { content: '${number}'; }\n`
    }
    keyframes += '}'

    const css = `
      #${id}:before {
        content: '';
        font-size: 4em;
        color: white;
        animation: count-${duration} ${duration}s forwards;
      }
      ${keyframes}
    `

    // Inject the CSS
    const style = document.createElement('style')
    style.id = `style-${id}`
    style.textContent = css
    document.head.appendChild(style)
  }

  advanceStage() {
    console.log(`Auto-advancing to stage ${this.nextStageValue}`)

    const url = `/sessions/${this.sessionUuidValue}/advance_stage/${this.nextStageValue}`

    fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => {
      if (response.ok) {
        console.log('Stage advance triggered successfully')
      } else {
        console.error('Failed to advance stage:', response.status)
      }
    })
    .catch(error => {
      console.error('Error advancing stage:', error)
    })
  }

  // Action methods that can be called from the UI
  pauseAction() {
    this.pause()
  }

  resumeAction() {
    this.resume()
  }

  resetAction() {
    this.reset()
  }
}
