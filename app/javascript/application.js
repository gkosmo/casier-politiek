// Simple React setup
import React from 'react'
import { createRoot } from 'react-dom/client'
import Home from './components/Home'

// Initialize React when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('root')
  if (container) {
    const root = createRoot(container)
    root.render(<Home />)
  }
})
