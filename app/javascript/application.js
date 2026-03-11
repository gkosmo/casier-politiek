// Superglue setup
import React from 'react'
import { createRoot } from 'react-dom/client'
import { Application } from '@thoughtbot/superglue'
import { configureStore } from '@reduxjs/toolkit'
import { rootReducer } from '@thoughtbot/superglue'

// Import your pages
import Home from './components/Home'

const pages = {
  '/pages/home': Home,
  '/': Home
}

// Create Redux store
const store = configureStore({
  reducer: rootReducer,
})

// Initialize Superglue when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('root')
  if (container) {
    const initialPage = JSON.parse(container.dataset.pageData || '{}')
    const baseUrl = window.location.origin
    const path = window.location.pathname

    const root = createRoot(container)
    root.render(
      <Application
        initialPage={initialPage}
        baseUrl={baseUrl}
        path={path}
        store={store}
        mapping={pages}
      />
    )
  }
})
