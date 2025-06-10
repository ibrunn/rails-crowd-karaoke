// app/javascript/controllers/song_vote_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count", "total"]
  static values = {
    sessionUuid: String,
    gameSessionSongId: Number
  }

  connect() {
    console.log("Song vote controller connected for song:", this.gameSessionSongIdValue)
  }

  vote() {
    // Add visual feedback
    this.addVoteAnimation()

    // Send vote via AJAX
    this.submitVote()
  }

  addVoteAnimation() {
    const card = this.element.querySelector('.card')

    // Add clicked animation
    card.style.transform = 'scale(0.95)'
    card.style.backgroundColor = '#e3f2fd'

    setTimeout(() => {
      card.style.transform = 'scale(1)'
      card.style.backgroundColor = ''
    }, 150)
  }

  submitVote() {
    const url = `/sessions/${this.sessionUuidValue}/song_votes`

    const formData = new FormData()
    formData.append('song_vote[game_session_song_id]', this.gameSessionSongIdValue)

    // Add CSRF token
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
    if (token) {
      formData.append('authenticity_token', token)
    }

    fetch(url, {
      method: 'POST',
      body: formData,
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.updateVoteCount(data.vote_count)
        this.updateTotalVotes(data.total_votes)
        this.showFeedback(data.message)
      } else {
        console.error('Vote failed:', data.message)
      }
    })
    .catch(error => {
      console.error('Error submitting vote:', error)
    })
  }

  updateVoteCount(newCount) {
    if (this.hasCountTarget) {
      this.countTarget.textContent = `Your votes: ${newCount}`

      // Add pulse animation
      this.countTarget.style.animation = 'pulse 0.3s ease-in-out'
      setTimeout(() => {
        this.countTarget.style.animation = ''
      }, 300)
    }
  }

  updateTotalVotes(totalVotes) {
    // Update total across all song vote controllers
    const totalTargets = document.querySelectorAll('[data-song-vote-target="total"]')
    totalTargets.forEach(target => {
      target.textContent = totalVotes
      target.style.animation = 'pulse 0.3s ease-in-out'
      setTimeout(() => {
        target.style.animation = ''
      }, 300)
    })
  }

  showFeedback(message) {
    // Create temporary feedback element
    const feedback = document.createElement('div')
    feedback.className = 'vote-feedback'
    feedback.textContent = '🎵 +1'
    feedback.style.cssText = `
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      background: #4CAF50;
      color: white;
      padding: 8px 16px;
      border-radius: 20px;
      font-weight: bold;
      z-index: 1000;
      animation: voteSuccess 1s ease-out forwards;
    `

    // Add CSS animation if not already present
    if (!document.querySelector('#vote-success-style')) {
      const style = document.createElement('style')
      style.id = 'vote-success-style'
      style.textContent = `
        @keyframes voteSuccess {
          0% {
            opacity: 0;
            transform: translate(-50%, -50%) scale(0.5);
          }
          50% {
            opacity: 1;
            transform: translate(-50%, -50%) scale(1.2);
          }
          100% {
            opacity: 0;
            transform: translate(-50%, -50%) scale(1) translateY(-30px);
          }
        }
        @keyframes pulse {
          0%, 100% { transform: scale(1); }
          50% { transform: scale(1.1); }
        }
      `
      document.head.appendChild(style)
    }

    this.element.style.position = 'relative'
    this.element.appendChild(feedback)

    // Remove feedback after animation
    setTimeout(() => {
      feedback.remove()
    }, 1000)
  }
}
