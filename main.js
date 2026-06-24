// Import CSS to let Vite bundle it
import './style.css';

document.addEventListener('DOMContentLoaded', () => {
  initShowcaseTabs();
  initInteractiveNotch();
  initScrollEffects();
  initPremiumInteractions();
});

/**
 * 1. Interactive Showcase Tabs
 * Switches screenshots and titles with smooth fade transitions
 */
function initShowcaseTabs() {
  const tabs = document.querySelectorAll('.tab-btn');
  const previewImg = document.getElementById('showcase-img-element');
  const previewTitle = document.getElementById('preview-title');
  const heroPreview = document.getElementById('hero-preview-img');
  const macbookFrame = document.querySelector('.macbook-frame');

  const tabData = {
    sports: {
      image: '/assets/sports_view.png',
      title: 'Sports Live Updates',
      desc: 'Track scores & standings directly beneath the notch.'
    },
    calendar: {
      image: '/assets/calendar_view.png',
      title: 'Calendar & Meeting Agenda',
      desc: 'View your upcoming standups and day agenda in one place.'
    },
    clipboard: {
      image: '/assets/clipboard_view.png',
      title: 'Clipboard Manager',
      desc: 'One-click copy for emails, SSH codes, and snippet prompt templates.'
    },
    todo: {
      image: '/assets/todo_view.png',
      title: 'Quick To-Do Tasks',
      desc: 'Quickly add checklist items and drag/drop to reorder.'
    },
    music: {
      image: '/assets/music_view.png',
      title: 'System Media Controller',
      desc: 'Control playback track progress and toggle inputs on Apple Music/Spotify.'
    },
    stocks: {
      image: '/assets/stocks_view.png',
      title: 'Stocks & Indices Tracker',
      desc: 'Monitor real-time prices, percentage gains, and sparkline charts.'
    },
    notchbar: {
      image: '/assets/notch_bar_view.png',
      title: 'Live Notch Status Bar',
      desc: 'Get glanceable active indicators right on the notch bezel itself.'
    }
  };

  // Notchbar sub-tabs selection logic
  const subBtns = document.querySelectorAll('.sub-tab-btn');
  subBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      subBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      
      const newImg = btn.getAttribute('data-sub-img');
      if (previewImg && newImg) {
        previewImg.classList.add('fade-out');
        setTimeout(() => {
          previewImg.src = newImg;
          previewImg.classList.remove('fade-out');
        }, 150);
      }
    });
  });

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const tabId = tab.getAttribute('data-tab');
      if (!tabId || !tabData[tabId]) return;

      // Remove active from all tabs
      tabs.forEach(btn => btn.classList.remove('active'));
      
      // Add active to current
      tab.classList.add('active');

      // Show/hide notchbar options sub-selector
      const subSelector = document.getElementById('notchbar-sub-selector');
      if (subSelector) {
        if (tabId === 'notchbar') {
          subSelector.style.display = 'flex';
          subBtns.forEach(b => b.classList.remove('active'));
          if (subBtns[0]) subBtns[0].classList.add('active');
        } else {
          subSelector.style.display = 'none';
        }
      }

      // Trigger fade transition
      if (previewImg) {
        previewImg.classList.add('fade-out');
      }

      // Quick visual spring reaction on MacBook frame mockup
      if (macbookFrame) {
        macbookFrame.style.transform = 'scale(0.985) translateY(2px)';
        setTimeout(() => {
          macbookFrame.style.transform = 'scale(1) translateY(0)';
        }, 150);
      }

      setTimeout(() => {
        // Update screenshot and title
        if (previewImg) {
          previewImg.src = tabData[tabId].image;
          previewImg.alt = tabData[tabId].title;
        }
        if (previewTitle) {
          previewTitle.textContent = tabData[tabId].title;
        }
        
        // Fade in
        if (previewImg) {
          previewImg.classList.remove('fade-out');
        }
      }, 200);
    });
  });
}

/**
 * 2. Top Page Notch Interactivity
 * Simulates actions within the floating notch (play/pause and live score updates)
 */
function initInteractiveNotch() {
  const pageNotch = document.getElementById('page-notch');
  const playBtn = document.querySelector('.play-btn');
  const progressFill = document.querySelector('.progress-fill');
  const liveIndicatorText = document.querySelector('.indicator-text');
  
  if (!pageNotch) return;

  // Track progress bar animation simulation when play button is active
  let isPlaying = true;
  let progressPercent = 45;
  let progressInterval;

  function startProgress() {
    progressInterval = setInterval(() => {
      if (progressPercent >= 100) {
        progressPercent = 0;
      } else {
        progressPercent += 0.4;
      }
      if (progressFill) {
        progressFill.style.width = `${progressPercent}%`;
      }
    }, 1000);
  }

  // Start by default
  startProgress();

  if (playBtn) {
    playBtn.addEventListener('click', (e) => {
      e.stopPropagation(); // Avoid triggering parent expand/collapse
      
      const icon = playBtn.querySelector('i');
      if (!icon) return;

      if (isPlaying) {
        // Pause
        isPlaying = false;
        icon.className = 'fa-solid fa-play';
        clearInterval(progressInterval);
        document.querySelector('.widget-status').textContent = 'Paused';
      } else {
        // Play
        isPlaying = true;
        icon.className = 'fa-solid fa-pause';
        document.querySelector('.widget-status').textContent = 'Live Session';
        startProgress();
      }
    });
  }

  // Live score dynamic simulation (cycles names every 10s)
  const scores = [
    "COD 0 - 0 COL 59'",
    "COD 0 - 1 COL 64'",
    "COD 1 - 1 COL 78'",
    "COD 1 - 2 COL 89' FT"
  ];
  let scoreIdx = 0;

  setInterval(() => {
    scoreIdx = (scoreIdx + 1) % scores.length;
    if (liveIndicatorText) {
      liveIndicatorText.style.opacity = '0';
      setTimeout(() => {
        liveIndicatorText.textContent = scores[scoreIdx];
        liveIndicatorText.style.opacity = '1';
      }, 300);
    }
  }, 12000);
}

/**
 * 3. Page Scroll Effects
 * Adds visual updates to header and notch on scroll
 */
function initScrollEffects() {
  const header = document.querySelector('.navbar-container');
  const pageNotch = document.getElementById('page-notch');

  window.addEventListener('scroll', () => {
    const scrollPos = window.scrollY;

    // Sticky Header backdrop blur intensity increase
    if (header) {
      if (scrollPos > 40) {
        header.style.padding = '8px 24px';
        header.style.background = 'rgba(10, 10, 12, 0.85)';
        header.style.borderColor = 'rgba(255, 255, 255, 0.12)';
        header.style.boxShadow = '0 12px 40px rgba(0, 0, 0, 0.5)';
      } else {
        header.style.padding = '12px 24px';
        header.style.background = 'rgba(10, 10, 12, 0.6)';
        header.style.borderColor = 'var(--border-color)';
        header.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.3)';
      }
    }

    // Fade out page notch on deep scroll to keep content clean
    if (pageNotch) {
      if (scrollPos > 400) {
        if (!pageNotch.matches(':hover')) {
          pageNotch.style.opacity = '0.35';
        }
      } else {
        pageNotch.style.opacity = '1';
      }
    }
  });

  if (pageNotch) {
    pageNotch.addEventListener('mouseenter', () => {
      pageNotch.style.opacity = '1';
    });
    pageNotch.addEventListener('mouseleave', () => {
      if (window.scrollY > 400) {
        pageNotch.style.opacity = '0.35';
      }
    });
  }
}

/**
 * 4. Premium Micro-Interactions
 * Interactive copy tooltip simulations & card glows
 */
function initPremiumInteractions() {
  // Add direct click listener to copy buttons and fields
  const downloadBtn = document.getElementById('btn-dmg-download');
  
  if (downloadBtn) {
    downloadBtn.addEventListener('click', (e) => {
      e.preventDefault();
      
      // Visual feedback on click
      const originalText = downloadBtn.innerHTML;
      downloadBtn.innerHTML = '<i class="fa-solid fa-circle-check text-green"></i> Packaging installer...';
      downloadBtn.style.borderColor = 'var(--accent-green)';
      downloadBtn.style.color = 'var(--accent-green)';
      
      setTimeout(() => {
        downloadBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Downloading NotchDock...';
        
        setTimeout(() => {
          downloadBtn.innerHTML = originalText;
          downloadBtn.style.borderColor = '';
          downloadBtn.style.color = '';
          
          // Redirect to github releases
          window.location.href = 'https://github.com/rohanrony/notchdock/releases/';
        }, 1200);
      }, 1000);
    });
  }

  // Interactive mouse visual glow follow for feature cards
  const cards = document.querySelectorAll('.feature-card');
  cards.forEach(card => {
    card.addEventListener('mousemove', (e) => {
      const rect = card.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      
      card.style.setProperty('--mouse-x', `${x}px`);
      card.style.setProperty('--mouse-y', `${y}px`);
    });
  });
}
