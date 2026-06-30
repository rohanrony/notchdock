// Import CSS to let Vite bundle it
import './style.css';

document.addEventListener('DOMContentLoaded', () => {
  initShowcaseTabs();
  initInteractiveNotch();
  initScrollEffects();
  initPremiumInteractions();
  initUnifiedAutoRotation();
});

/**
 * 1. Interactive Showcase Tabs
 * Switches screenshots and titles with smooth fade transitions
 */
// State variables for interactive showcase
const showState = {
  sports: {
    currentTab: 'today',
    matches: [
      { id: 's1', teamA: 'Qatar', recordA: '0-1-1', flagA: '🇶🇦', teamB: 'Bosnia-Herzegovina', recordB: '0-1-1', flagB: '🇧🇦', time: '3:00 PM', starLeft: true, starRight: false, selected: false },
      { id: 's2', teamA: 'Canada', recordA: '1-1-0', flagA: '🇨🇦', teamB: 'Switzerland', recordB: '1-1-0', flagB: '🇨🇭', time: '3:00 PM', starLeft: false, starRight: false, selected: true },
      { id: 's3', teamA: 'Haiti', recordA: '0-0-2', flagA: '🇭🇹', teamB: 'Morocco', recordB: '1-1-0', flagB: '🇲🇦', time: '6:00 PM', starLeft: false, starRight: true, selected: false },
      { id: 's4', teamA: 'Brazil', recordA: '1-1-0', flagA: '🇧🇷', teamB: 'Scotland', recordB: '1-0-1', flagB: '🏴󠁧󠁢󠁳󠁣󠁴󠁿', time: '6:00 PM', starLeft: true, starRight: false, selected: false },
      { id: 's5', teamA: 'Mexico', recordA: '2-0-0', flagA: '🇲🇽', teamB: 'Czechia', recordB: '0-1-1', flagB: '🇨🇿', time: '9:00 PM', starLeft: false, starRight: false, selected: false },
      { id: 's6', teamA: 'South Korea', recordA: '1-0-1', flagA: '🇰🇷', teamB: 'South Africa', recordB: '0-1-1', flagB: '🇿🇦', time: '9:00 PM', starLeft: false, starRight: false, selected: false }
    ]
  },
  calendar: {
    selectedDay: 23,
    events: [
      { id: 1, time: 'Jun 25, 10:00 AM', title: 'Software Standup' },
      { id: 2, time: 'Jun 26, 10:45 AM', title: 'AI Standup' },
      { id: 3, time: 'Jun 29, 10:45 AM', title: 'AI Standup' }
    ]
  },
  clipboard: {
    search: '',
    toastTimeout: null,
    items: [
      { id: 'c1', label: 'My Prompt', content: 'Please review the following text for clarity, tone, and grammar' },
      { id: 'c2', label: 'ID#', content: '#00000000' },
      { id: 'c3', label: "Rohan's email", content: 'hello@notchdock.app' },
      { id: 'c4', label: 'SSH', content: 'ssh root@192.168.1.1' },
      { id: 'c5', label: 'Edit this', content: 'Copy this -> (Hover to see icons)' }
    ]
  },
  todo: {
    tasks: [
      { id: 1, text: 'Welcome to NotchDock ToDo', completed: false },
      { id: 2, text: 'Drag and drop to reorder', completed: false },
      { id: 3, text: 'Tap to and/or delete', completed: true }
    ]
  },
  music: {
    isPlaying: false,
    activeTrackIndex: 0,
    progress: 0, // in percent
    volume: 75,
    interval: null,
    tracks: [
      { title: 'Midnight City', artist: 'M83', album: "Hurry Up, We're Dreaming", duration: 243 },
      { title: 'Get Lucky', artist: 'Daft Punk', album: 'Random Access Memories', duration: 249 },
      { title: 'Starboy', artist: 'The Weeknd', album: 'Starboy', duration: 230 }
    ]
  },
  stocks: {
    activeSymbol: '^IXIC',
    tickerInterval: null,
    indices: [
      {
        symbol: '^DJI',
        name: 'Dow Jones Industrial Average',
        price: 52142.21,
        change: 475.37,
        changePercent: 0.92,
        open: 51701.37,
        high: 52247.23,
        low: 51701.37,
        vol: '175.1M',
        bookmarked: false,
        sparkline: 'M 0 15 L 10 13 L 20 10 L 30 7 L 40 5 L 50 6'
      },
      {
        symbol: '^IXIC',
        name: 'NASDAQ Composite Index',
        price: 25750.10,
        change: 163.06,
        changePercent: 0.64,
        open: 25638.91,
        high: 25827.33,
        low: 25634.08,
        vol: '7.2B',
        bookmarked: true,
        sparkline: 'M 0 16 L 10 17 L 20 12 L 30 6 L 40 10 L 50 10'
      },
      {
        symbol: '^GSPC',
        name: 'S&P 500 Index',
        price: 7410.74,
        change: 45.28,
        changePercent: 0.61,
        open: 7386.25,
        high: 7424.92,
        low: 7384.21,
        vol: '1.2B',
        bookmarked: true,
        sparkline: 'M 0 15 L 10 16 L 20 11 L 30 8 L 40 11 L 50 11'
      }
    ]
  },
  notchbar: {
    mode: 'default',
    notchSize: 'medium',
    wallpaper: 'monterey-pink',
    timerRunning: false,
    timerSeconds: 1500,
    timerInterval: null
  }
};

function escapeHTML(str) {
  return str.replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
}

function getWidgetHeaderHTML(activeTab) {
  const sportsFieldSVG = `<svg class="nd-hdr-icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 14px; height: 14px; display: inline-block; vertical-align: middle;"><rect x="2" y="4" width="20" height="16" rx="2" /><line x1="12" y1="4" x2="12" y2="20" /><circle cx="12" cy="12" r="4" /></svg>`;
  
  return `
    <div class="nd-widget-header">
      <div class="nd-widget-header-left">
        <i class="fa-regular fa-calendar nd-hdr-icon ${activeTab === 'calendar' ? 'active' : ''}" data-tab-nav="calendar" title="Calendar"></i>
        <span class="nd-hdr-icon ${activeTab === 'sports' ? 'active' : ''}" data-tab-nav="sports" title="Sports" style="display: flex; align-items: center; justify-content: center;">
          ${sportsFieldSVG}
        </span>
        <i class="fa-solid fa-list-check nd-hdr-icon ${activeTab === 'todo' ? 'active' : ''}" data-tab-nav="todo" title="To-Do List"></i>
        <i class="fa-solid fa-music nd-hdr-icon ${activeTab === 'music' ? 'active' : ''}" data-tab-nav="music" title="Media Player"></i>
        <i class="fa-solid fa-chart-line nd-hdr-icon ${activeTab === 'stocks' ? 'active' : ''}" data-tab-nav="stocks" title="Stocks"></i>
      </div>
      <div class="nd-widget-header-right">
        <i class="fa-solid fa-clock-rotate-left nd-hdr-icon ${activeTab === 'notchbar' ? 'active' : ''}" data-tab-nav="notchbar" title="Live Status Bar"></i>
        <i class="fa-regular fa-clipboard nd-hdr-icon ${activeTab === 'clipboard' ? 'active' : ''}" data-tab-nav="clipboard" title="Clipboard"></i>
        <i class="fa-solid fa-thumbtack nd-hdr-icon static-icon" title="Pin Widget"></i>
        <i class="fa-solid fa-compress nd-hdr-icon static-icon" title="Minimize"></i>
        <i class="fa-solid fa-gear nd-hdr-icon static-icon" title="Settings"></i>
      </div>
    </div>
  `;
}

function updatePageNotchScoreboard() {
  const liveIndicatorText = document.querySelector('.indicator-text');
  if (!liveIndicatorText) return;
  
  const followed = showState.sports.matches.find(m => m.starLeft || m.starRight);
  if (followed) {
    liveIndicatorText.textContent = `${followed.teamA.substring(0,3).toUpperCase()} 0 - 0 ${followed.teamB.substring(0,3).toUpperCase()} Live`;
  } else {
    liveIndicatorText.textContent = "COD 0 - 0 COL 59'";
  }
}

// 1. Sports Widget Renderer
function renderSportsWidget() {
  const container = document.getElementById('showcase-interactive-container');
  if (!container) return;
  
  const state = showState.sports;

  if (state.matchDetailsId) {
    const match = state.matches.find(m => m.id === state.matchDetailsId) || state.matches[0];
    
    container.innerHTML = `
      <div class="nd-widget nd-widget-sports-details">
        <div class="nd-md-header">
          <button class="nd-md-back" id="nd-md-back-btn"><i class="fa-solid fa-chevron-left"></i></button>
          <span>⚽ FIFA World Cup 2026</span>
          <div style="width: 24px;"></div>
        </div>
        
        <div class="nd-match-scoreboard">
          <div class="nd-md-team">
            <span class="nd-md-flag">${match.flagA}</span>
            <span class="nd-md-name">${match.teamA}</span>
            <span class="nd-md-record">${match.recordA}</span>
          </div>
          <div class="nd-md-center">
            <div class="nd-md-score">2 <span class="nd-md-dash">-</span> 0</div>
            <div class="nd-md-time"><span class="live-dot" style="color: #ff453a;">🔴</span> 90'+3'</div>
          </div>
          <div class="nd-md-team right">
            <span class="nd-md-flag">${match.flagB}</span>
            <span class="nd-md-name">${match.teamB}</span>
            <span class="nd-md-record">${match.recordB}</span>
          </div>
        </div>

        <div class="nd-md-section-title">TEAM STATISTICS</div>
        <div class="nd-md-stats">
          <div class="nd-md-stat-row">
            <div class="nd-md-stat-labels"><span>49%</span><span class="nd-md-stat-name">POSSESSION</span><span>51%</span></div>
            <div class="nd-md-stat-bars"><div class="nd-md-bar left"><div class="fill bg-green" style="width: 49%;"></div></div><div class="nd-md-bar right"><div class="fill bg-red" style="width: 51%;"></div></div></div>
          </div>
          <div class="nd-md-stat-row">
            <div class="nd-md-stat-labels"><span>90%</span><span class="nd-md-stat-name">PASSING ACCURACY</span><span>80%</span></div>
            <div class="nd-md-stat-bars"><div class="nd-md-bar left"><div class="fill bg-green" style="width: 90%;"></div></div><div class="nd-md-bar right"><div class="fill bg-red" style="width: 80%;"></div></div></div>
          </div>
          <div class="nd-md-stat-row">
            <div class="nd-md-stat-labels"><span>9 (3)</span><span class="nd-md-stat-name">SHOTS (ON TARGET)</span><span>12 (1)</span></div>
            <div class="nd-md-stat-bars"><div class="nd-md-bar left"><div class="fill bg-green" style="width: 42%;"></div></div><div class="nd-md-bar right"><div class="fill bg-red" style="width: 58%;"></div></div></div>
          </div>
          <div class="nd-md-stat-row">
            <div class="nd-md-stat-labels"><span>13</span><span class="nd-md-stat-name">FOULS</span><span>9</span></div>
            <div class="nd-md-stat-bars"><div class="nd-md-bar left"><div class="fill bg-green" style="width: 59%;"></div></div><div class="nd-md-bar right"><div class="fill bg-red" style="width: 41%;"></div></div></div>
          </div>
          <div class="nd-md-stat-row">
            <div class="nd-md-stat-labels"><span>1</span><span class="nd-md-stat-name">CORNERS</span><span>5</span></div>
            <div class="nd-md-stat-bars"><div class="nd-md-bar left"><div class="fill bg-green" style="width: 16%;"></div></div><div class="nd-md-bar right"><div class="fill bg-red" style="width: 84%;"></div></div></div>
          </div>
          <div class="nd-md-stat-row">
            <div class="nd-md-stat-labels"><span>0</span><span class="nd-md-stat-name">OFFSIDES</span><span>1</span></div>
            <div class="nd-md-stat-bars"><div class="nd-md-bar left"><div class="fill bg-green" style="width: 0%;"></div></div><div class="nd-md-bar right"><div class="fill bg-red" style="width: 100%;"></div></div></div>
          </div>
        </div>

        <div class="nd-md-section-title">MATCH EVENTS</div>
        <div class="nd-md-events">
          <div class="nd-md-event-row">
            <span class="nd-md-event-time">55'</span>
            <i class="fa-solid fa-futbol text-green"></i>
            <span class="nd-md-event-player">Mateo Chávez <span class="nd-md-badge blue">MEX</span></span>
          </div>
          <div class="nd-md-event-row">
            <span class="nd-md-event-time">61'</span>
            <i class="fa-solid fa-futbol text-green"></i>
            <span class="nd-md-event-player">Julián Quiñones <span class="nd-md-badge blue">MEX</span></span>
          </div>
          <div class="nd-md-event-row">
            <span class="nd-md-event-time">64'</span>
            <span style="color: #ffd60a; font-size: 0.8rem; margin: 0 4px;">🟨</span>
            <span class="nd-md-event-player">Edson Álvarez <span class="nd-md-badge blue">MEX</span></span>
          </div>
        </div>

        <div class="nd-md-section-title">KEY PERFORMERS</div>
        <div class="nd-md-performers">
          <div class="nd-md-perf-card">
            <div class="nd-md-perf-avatar"><i class="fa-solid fa-user"></i></div>
            <div class="nd-md-perf-info">
              <div class="nd-md-perf-name">Julián Quiñones</div>
              <div class="nd-md-perf-sub">MEX • 4</div>
            </div>
          </div>
          <div class="nd-md-perf-card">
            <div class="nd-md-perf-avatar"><i class="fa-solid fa-user"></i></div>
            <div class="nd-md-perf-info">
              <div class="nd-md-perf-name">Roberto Alvarado</div>
              <div class="nd-md-perf-sub">MEX • 44</div>
            </div>
          </div>
        </div>
      </div>
    `;

    container.querySelector('#nd-md-back-btn').addEventListener('click', () => {
      state.matchDetailsId = null;
      const sportsTabBtn = document.getElementById('tab-sports');
      if (sportsTabBtn) sportsTabBtn.click();
      else renderSportsWidget();
    });
    return;
  }
  
  let listHTML = '';
  if (state.currentTab === 'past') {
    const pastMatches = [
      { id: 'p1', teamA: 'Ecuador', recordA: '1-0-2', flagA: '🇪🇨', scoreA: 1, scoreB: 2, teamB: 'Senegal', recordB: '2-0-1', flagB: '🇸🇳', time: 'FT' },
      { id: 'p2', teamA: 'Netherlands', recordA: '2-1-0', flagA: '🇳🇱', scoreA: 0, scoreB: 0, teamB: 'Ecuador', recordB: '1-1-1', flagB: '🇪🇨', time: 'FT' }
    ];
    pastMatches.forEach(m => {
      listHTML += `
        <div class="nd-sports-row" data-match-id="${m.id}">
          <span class="nd-sports-star"><i class="fa-regular fa-star"></i></span>
          <div class="nd-sports-team-name-left">${m.teamA}<span class="nd-sports-record">${m.recordA}</span></div>
          <span class="nd-sports-flag">${m.flagA}</span>
          <span class="nd-sports-mid-text">${m.scoreA} - ${m.scoreB}</span>
          <span class="nd-sports-flag">${m.flagB}</span>
          <div class="nd-sports-team-name-right">${m.teamB}<span class="nd-sports-record">${m.recordB}</span></div>
          <span class="nd-sports-star"><i class="fa-regular fa-star"></i></span>
        </div>
      `;
    });
  } else if (state.currentTab === 'upcoming') {
    const upcomingMatches = [
      { id: 'u1', teamA: 'USA', recordA: '2-0-0', flagA: '🇺🇸', teamB: 'England', recordB: '1-1-0', flagB: '🏴󠁧󠁢󠁥󠁮󠁧󠁿', time: 'June 25' },
      { id: 'u2', teamA: 'Argentina', recordA: '3-0-0', flagA: '🇦🇷', teamB: 'Mexico', recordB: '2-0-0', flagB: '🇲🇽', time: 'June 26' }
    ];
    upcomingMatches.forEach(m => {
      listHTML += `
        <div class="nd-sports-row" data-match-id="${m.id}">
          <span class="nd-sports-star"><i class="fa-regular fa-star"></i></span>
          <div class="nd-sports-team-name-left">${m.teamA}<span class="nd-sports-record">${m.recordA}</span></div>
          <span class="nd-sports-flag">${m.flagA}</span>
          <span class="nd-sports-mid-text" style="font-size: 0.65rem; color: var(--text-muted);">${m.time}</span>
          <span class="nd-sports-flag">${m.flagB}</span>
          <div class="nd-sports-team-name-right">${m.teamB}<span class="nd-sports-record">${m.recordB}</span></div>
          <span class="nd-sports-star"><i class="fa-regular fa-star"></i></span>
        </div>
      `;
    });
  } else if (state.currentTab === 'standings') {
    listHTML = `
      <div style="padding: 10px 16px;">
        <table style="width: 100%; border-collapse: collapse; font-size: 0.72rem; color: var(--text-white); text-align: left;">
          <thead>
            <tr style="border-bottom: 1px solid rgba(255, 255, 255, 0.1); color: var(--text-muted);">
              <th style="padding: 6px;">Team</th>
              <th>W</th>
              <th>D</th>
              <th>L</th>
              <th>GD</th>
              <th>PTS</th>
            </tr>
          </thead>
          <tbody>
            <tr><td style="padding: 6px; font-weight: 600;">🇲🇽 Mexico</td><td>2</td><td>0</td><td>0</td><td>+4</td><td>6</td></tr>
            <tr><td style="padding: 6px; font-weight: 600;">🇨🇦 Canada</td><td>1</td><td>1</td><td>0</td><td>+2</td><td>4</td></tr>
            <tr><td style="padding: 6px; font-weight: 600;">🇨🇭 Switzerland</td><td>1</td><td>1</td><td>0</td><td>+1</td><td>4</td></tr>
            <tr><td style="padding: 6px; font-weight: 600;">🇧🇦 Bosnia-H.</td><td>0</td><td>1</td><td>1</td><td>-2</td><td>1</td></tr>
          </tbody>
        </table>
      </div>
    `;
  } else {
    state.matches.forEach(m => {
      listHTML += `
        <div class="nd-sports-row ${m.selected ? 'live-active' : ''}" data-id="${m.id}">
          <span class="nd-sports-star ${m.starLeft ? 'active' : ''}" data-star="left" data-id="${m.id}">
            <i class="fa-solid fa-star"></i>
          </span>
          <div class="nd-sports-team-name-left">${m.teamA}<span class="nd-sports-record">${m.recordA}</span></div>
          <span class="nd-sports-flag">${m.flagA}</span>
          <span class="nd-sports-mid-text">${m.time}</span>
          <span class="nd-sports-flag">${m.flagB}</span>
          <div class="nd-sports-team-name-right">${m.teamB}<span class="nd-sports-record">${m.recordB}</span></div>
          <span class="nd-sports-star ${m.starRight ? 'active' : ''}" data-star="right" data-id="${m.id}">
            <i class="fa-solid fa-star"></i>
          </span>
        </div>
      `;
    });
  }

  container.innerHTML = `
    <div class="nd-widget nd-sports-widget">
      ${getWidgetHeaderHTML('sports')}
      <div class="nd-sports-top-row">
        <div class="nd-segmented-control">
          <button class="nd-segment-btn ${state.currentTab === 'past' ? 'active' : ''}" data-sports-tab="past">Past</button>
          <button class="nd-segment-btn ${state.currentTab === 'today' || !state.currentTab ? 'active' : ''}" data-sports-tab="today">Today</button>
          <button class="nd-segment-btn ${state.currentTab === 'upcoming' ? 'active' : ''}" data-sports-tab="upcoming">Upcoming</button>
          <button class="nd-segment-btn ${state.currentTab === 'standings' ? 'active' : ''}" data-sports-tab="standings">Standings</button>
        </div>
        <div class="nd-sports-dropdown">
          <span>🏆 FIFA WC '26</span>
          <i class="fa-solid fa-chevron-down" style="font-size: 0.65rem;"></i>
        </div>
      </div>
      <div class="nd-sports-list">
        ${listHTML}
      </div>
    </div>
  `;

  // Bind sports subtabs
  container.querySelectorAll('[data-sports-tab]').forEach(btn => {
    btn.addEventListener('click', () => {
      state.currentTab = btn.getAttribute('data-sports-tab');
      renderSportsWidget();
    });
  });

  // Bind stars
  container.querySelectorAll('.nd-sports-star').forEach(star => {
    star.addEventListener('click', (e) => {
      e.stopPropagation();
      const id = star.getAttribute('data-id');
      const side = star.getAttribute('data-star');
      const match = state.matches.find(m => m.id === id);
      if (match) {
        if (side === 'left') match.starLeft = !match.starLeft;
        if (side === 'right') match.starRight = !match.starRight;
        updatePageNotchScoreboard();
        renderSportsWidget();
      }
    });
  });

  // Bind row selection
  container.querySelectorAll('.nd-sports-row').forEach(row => {
    row.addEventListener('click', () => {
      const id = row.getAttribute('data-id');
      if (!id) return;
      state.matches.forEach(m => m.selected = (m.id === id));
      state.matchDetailsId = id;
      renderSportsWidget();
    });
  });
}

// 2. Calendar Widget Renderer
function renderCalendarWidget() {
  const container = document.getElementById('showcase-interactive-container');
  if (!container) return;

  const state = showState.calendar;
  const selectedDay = state.selectedDay || 23;

  const cells = [
    { day: 31, currentMonth: false },
    { day: 1, currentMonth: true },
    { day: 2, currentMonth: true },
    { day: 3, currentMonth: true },
    { day: 4, currentMonth: true },
    { day: 5, currentMonth: true },
    { day: 6, currentMonth: true },
    { day: 7, currentMonth: true },
    { day: 8, currentMonth: true, hasEvent: true },
    { day: 9, currentMonth: true, hasEvent: true },
    { day: 10, currentMonth: true },
    { day: 11, currentMonth: true, hasEvent: true },
    { day: 12, currentMonth: true, hasEvent: true },
    { day: 13, currentMonth: true },
    { day: 14, currentMonth: true },
    { day: 15, currentMonth: true, hasEvent: true },
    { day: 16, currentMonth: true, hasEvent: true },
    { day: 17, currentMonth: true },
    { day: 18, currentMonth: true, hasEvent: true },
    { day: 19, currentMonth: true, hasEvent: true },
    { day: 20, currentMonth: true },
    { day: 21, currentMonth: true, hasEvent: true },
    { day: 22, currentMonth: true, hasEvent: true },
    { day: 23, currentMonth: true, selected: true },
    { day: 24, currentMonth: true, hasEvent: true },
    { day: 25, currentMonth: true, hasEvent: true },
    { day: 26, currentMonth: true, hasEvent: true },
    { day: 27, currentMonth: true, hasEvent: true },
    { day: 28, currentMonth: true },
    { day: 29, currentMonth: true, hasEvent: true },
    { day: 30, currentMonth: true, hasEvent: true },
    { day: 1, currentMonth: false },
    { day: 2, currentMonth: false },
    { day: 3, currentMonth: false },
    { day: 4, currentMonth: false }
  ];

  let gridHTML = '';
  cells.forEach(c => {
    let classes = 'nd-cal-cell';
    if (c.currentMonth) classes += ' active-month';
    if (c.hasEvent) classes += ' has-event';
    if (c.currentMonth && c.day === selectedDay) classes += ' selected-day';
    gridHTML += `<div class="${classes}" data-day="${c.day}">${c.day}</div>`;
  });

  let nextEventTitle = 'AI Standup';
  let nextEventTime = 'Jun 24, 10:45 AM';
  if (selectedDay === 23) {
    nextEventTitle = 'AI Standup';
    nextEventTime = 'Jun 24, 10:45 AM';
  } else if (selectedDay === 24) {
    nextEventTitle = 'Software Standup';
    nextEventTime = 'Jun 25, 10:00 AM';
  } else if (selectedDay === 25) {
    nextEventTitle = 'Design Sync';
    nextEventTime = 'Jun 26, 11:30 AM';
  } else if (selectedDay === 22) {
    nextEventTitle = 'Marketing review';
    nextEventTime = 'Jun 22, 2:00 PM';
  } else {
    nextEventTitle = 'No events scheduled';
    nextEventTime = 'For selected date';
  }

  container.innerHTML = `
    <div class="nd-widget nd-calendar-widget">
      ${getWidgetHeaderHTML('calendar')}
      <div class="nd-cal-layout">
        <div class="nd-cal-left">
          <div class="nd-cal-grid-nav">
            <button class="nd-cal-grid-nav-btn"><i class="fa-solid fa-chevron-left"></i></button>
            <span>June 2026</span>
            <button class="nd-cal-grid-nav-btn"><i class="fa-solid fa-chevron-right"></i></button>
          </div>
          <div class="nd-cal-grid-header">
            <span>S</span><span>M</span><span>T</span><span>W</span><span>T</span><span>F</span><span>S</span>
          </div>
          <div class="nd-cal-grid">
            ${gridHTML}
          </div>
        </div>

        <div class="nd-cal-center">
          <div class="nd-cal-column-title">NEXT EVENT</div>
          <div class="nd-cal-next-event-title">${nextEventTitle}</div>
          <div class="nd-cal-next-event-time">${nextEventTime}</div>
          <div class="nd-cal-wave-divider">
            -::-~-::~-::~-::~-::~-::~-::~-<br>
            ::~-::~-::~-::~-::~-::~-::~-::~-<br>
            ~-::~-::~-::~-::~-::~-::~-
          </div>
        </div>

        <div class="nd-cal-right">
          <div class="nd-cal-column-title">UPCOMING</div>
          <div class="nd-cal-upcoming-list">
            <div class="nd-cal-upcoming-item">
              <i class="fa-solid fa-calendar-days nd-cal-upcoming-icon"></i>
              <div class="nd-cal-upcoming-details">
                <span class="nd-cal-upcoming-title">Software Standup</span>
                <span class="nd-cal-upcoming-time">Jun 25, 10:00 AM</span>
              </div>
            </div>
            <div class="nd-cal-upcoming-item">
              <i class="fa-solid fa-calendar-days nd-cal-upcoming-icon"></i>
              <div class="nd-cal-upcoming-details">
                <span class="nd-cal-upcoming-title">AI Standup</span>
                <span class="nd-cal-upcoming-time">Jun 26, 10:45 AM</span>
              </div>
            </div>
            <div class="nd-cal-upcoming-item">
              <i class="fa-solid fa-calendar-days nd-cal-upcoming-icon"></i>
              <div class="nd-cal-upcoming-details">
                <span class="nd-cal-upcoming-title">AI Standup</span>
                <span class="nd-cal-upcoming-time">Jun 29, 10:45 AM</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  `;

  container.querySelectorAll('.nd-cal-cell.active-month').forEach(cell => {
    cell.addEventListener('click', () => {
      state.selectedDay = parseInt(cell.getAttribute('data-day'));
      renderCalendarWidget();
    });
  });
}

// 3. Clipboard Widget Renderer
function renderClipboardWidget() {
  const container = document.getElementById('showcase-interactive-container');
  if (!container) return;

  const state = showState.clipboard;
  const query = state.search.toLowerCase().trim();

  const filtered = state.items.filter(item => 
    item.label.toLowerCase().includes(query) || 
    item.content.toLowerCase().includes(query)
  );

  let listHTML = '';
  if (filtered.length === 0) {
    listHTML = `<div style="text-align: center; color: var(--text-muted); font-size: 0.8rem; padding: 20px;">No clipboard items found</div>`;
  } else {
    filtered.forEach(item => {
      listHTML += `
        <div class="nd-clip-row" data-id="${item.id}">
          <div class="nd-clip-label">${escapeHTML(item.label)}</div>
          <div class="nd-clip-text">${escapeHTML(item.content)}</div>
        </div>
      `;
    });
  }

  container.innerHTML = `
    <div class="nd-widget nd-clipboard-widget">
      ${getWidgetHeaderHTML('clipboard')}
      <div class="nd-clipboard-toast" id="nd-clip-toast">Copied to Clipboard!</div>
      <div class="nd-clipboard-search-wrapper">
        <i class="fa-solid fa-magnifying-glass nd-clipboard-search-icon"></i>
        <input type="text" placeholder="Search clipboard history..." class="nd-clipboard-search" id="nd-clip-search-input" value="${escapeHTML(state.search)}" />
      </div>
      <div class="nd-clipboard-list">
        ${listHTML}
        <div class="nd-clip-bottom-add" id="nd-clip-add-btn">
          <i class="fa-solid fa-circle-plus" style="margin-right: 6px;"></i> Add Item to Quick Access Clipboard
        </div>
      </div>
    </div>
  `;

  const searchInput = container.querySelector('#nd-clip-search-input');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      state.search = e.target.value;
      renderClipboardWidget();
      const activeSearchInput = document.getElementById('nd-clip-search-input');
      if (activeSearchInput) {
        activeSearchInput.focus();
        activeSearchInput.setSelectionRange(activeSearchInput.value.length, activeSearchInput.value.length);
      }
    });
  }

  container.querySelectorAll('.nd-clip-row').forEach(row => {
    row.addEventListener('click', () => {
      const itemId = row.getAttribute('data-id');
      const item = state.items.find(i => i.id === itemId);
      if (!item) return;

      navigator.clipboard.writeText(item.content).catch(() => {});

      const toast = container.querySelector('#nd-clip-toast');
      if (toast) {
        toast.classList.add('show');
        clearTimeout(state.toastTimeout);
        state.toastTimeout = setTimeout(() => {
          toast.classList.remove('show');
        }, 1500);
      }
    });
  });

  const addBtn = container.querySelector('#nd-clip-add-btn');
  if (addBtn) {
    addBtn.addEventListener('click', () => {
      const label = prompt("Enter label for new clipboard item:");
      if (!label) return;
      const content = prompt("Enter text to copy:");
      if (!content) return;
      
      state.items.push({
        id: 'new-' + Date.now(),
        label,
        content
      });
      renderClipboardWidget();
    });
  }
}

// 4. To-Do Checklist Widget Renderer
function renderTodoWidget() {
  const container = document.getElementById('showcase-interactive-container');
  if (!container) return;

  const state = showState.todo;

  let listHTML = '';
  if (state.tasks.length === 0) {
    listHTML = `<div style="text-align: center; color: var(--text-muted); font-size: 0.8rem; padding: 20px;">No tasks left! Add a task below.</div>`;
  } else {
    state.tasks.forEach(task => {
      listHTML += `
        <div class="nd-todo-item ${task.completed ? 'completed' : ''}" data-id="${task.id}">
          <div class="nd-todo-left">
            <div class="nd-todo-checkbox ${task.completed ? 'checked' : ''}" data-id="${task.id}">
              ${task.completed ? '<i class="fa-solid fa-circle-check" style="color: var(--accent-green);"></i>' : '<i class="fa-regular fa-circle" style="color: rgba(255,255,255,0.25);"></i>'}
            </div>
            <span class="nd-todo-text" data-id="${task.id}">${escapeHTML(task.text)}</span>
          </div>
          <i class="fa-solid fa-bars nd-todo-grip"></i>
        </div>
      `;
    });
  }

  container.innerHTML = `
    <div class="nd-widget nd-todo-widget">
      ${getWidgetHeaderHTML('todo')}
      <div class="nd-todo-list">
        ${listHTML}
      </div>
      <div class="nd-todo-add-form">
        <i class="fa-solid fa-circle-plus nd-todo-add-icon" id="nd-todo-add-btn" style="cursor: pointer;"></i>
        <input type="text" placeholder="Add a task..." class="nd-todo-input" id="nd-todo-new-input" />
      </div>
    </div>
  `;

  container.querySelectorAll('.nd-todo-checkbox, .nd-todo-text').forEach(el => {
    el.addEventListener('click', () => {
      const id = parseInt(el.getAttribute('data-id'));
      const task = state.tasks.find(t => t.id === id);
      if (task) {
        if (task.completed) {
          state.tasks = state.tasks.filter(t => t.id !== id);
        } else {
          task.completed = true;
        }
        renderTodoWidget();
      }
    });
  });

  const addBtn = container.querySelector('#nd-todo-add-btn');
  const addInput = container.querySelector('#nd-todo-new-input');
  const submitTask = () => {
    const text = addInput.value.trim();
    if (!text) return;
    state.tasks.push({
      id: Date.now(),
      text: text,
      completed: false
    });
    renderTodoWidget();
  };

  if (addBtn && addInput) {
    addBtn.addEventListener('click', submitTask);
    addInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') submitTask();
    });
  }
}

// 5. Music Widget Renderer
function renderMusicWidget() {
  const container = document.getElementById('showcase-interactive-container');
  if (!container) return;

  const state = showState.music;
  const track = state.tracks[state.activeTrackIndex];

  const formatTime = (secs) => {
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m}:${s < 10 ? '0' : ''}${s}`;
  };

  const currentSecs = (state.progress / 100) * track.duration;
  const remainingSecs = track.duration - currentSecs;

  const titleText = state.isPlaying ? track.title : 'Not Playing';
  const artistText = state.isPlaying ? `${track.artist} — ${track.album}` : 'No Media Detected';

  container.innerHTML = `
    <div class="nd-widget nd-music-widget">
      ${getWidgetHeaderHTML('music')}
      <div class="nd-music-player">
        <div class="nd-music-art-container" style="background: linear-gradient(135deg, #d946ef, #a21caf);">
          <div class="nd-music-art-disc ${state.isPlaying ? 'playing' : ''}">
            <i class="fa-solid fa-music"></i>
          </div>
        </div>
        <div class="nd-music-details">
          <div class="nd-music-title">${escapeHTML(titleText)}</div>
          <div class="nd-music-artist">${escapeHTML(artistText)}</div>
        </div>
      </div>
      <div class="nd-music-controls-container">
        <div class="nd-music-timeline-box">
          <div class="nd-music-slider-wrapper">
            <input type="range" class="nd-music-slider" min="0" max="100" value="${state.progress}" id="nd-music-progress-slider" />
          </div>
          <div class="nd-music-time-labels">
            <span class="nd-music-time-current">${formatTime(currentSecs)}</span>
            <span class="nd-music-time-remaining">-${formatTime(remainingSecs)}</span>
          </div>
        </div>
        <div class="nd-music-btns">
          <button class="nd-music-btn" id="nd-music-prev"><i class="fa-solid fa-backward-step"></i></button>
          <button class="nd-music-btn play-toggle" id="nd-music-play">
            <i class="fa-solid ${state.isPlaying ? 'fa-pause' : 'fa-play'}"></i>
          </button>
          <button class="nd-music-btn" id="nd-music-next"><i class="fa-solid fa-forward-step"></i></button>
        </div>
      </div>
      <div class="nd-music-footer">
        No music sources authorized. Visit Settings.
      </div>
    </div>
  `;

  const startSimulation = () => {
    clearInterval(state.interval);
    state.interval = setInterval(() => {
      if (state.isPlaying) {
        const increment = (1 / track.duration) * 100;
        state.progress += increment;
        if (state.progress >= 100) {
          state.progress = 0;
          state.activeTrackIndex = (state.activeTrackIndex + 1) % state.tracks.length;
        }
        renderMusicWidget();
      }
    }, 1000);
  };

  if (state.isPlaying && !state.interval) {
    startSimulation();
  }

  const playBtn = container.querySelector('#nd-music-play');
  if (playBtn) {
    playBtn.addEventListener('click', () => {
      state.isPlaying = !state.isPlaying;
      if (state.isPlaying) {
        startSimulation();
      } else {
        clearInterval(state.interval);
        state.interval = null;
      }
      renderMusicWidget();
    });
  }

  const progressSlider = container.querySelector('#nd-music-progress-slider');
  if (progressSlider) {
    progressSlider.addEventListener('input', (e) => {
      state.progress = parseFloat(e.target.value);
      const updatedSecs = (state.progress / 100) * track.duration;
      container.querySelector('.nd-music-time-current').textContent = formatTime(updatedSecs);
      container.querySelector('.nd-music-time-remaining').textContent = `-${formatTime(track.duration - updatedSecs)}`;
    });
    progressSlider.addEventListener('change', (e) => {
      state.progress = parseFloat(e.target.value);
      renderMusicWidget();
    });
  }

  container.querySelector('#nd-music-prev').addEventListener('click', () => {
    state.activeTrackIndex = (state.activeTrackIndex - 1 + state.tracks.length) % state.tracks.length;
    state.progress = 0;
    renderMusicWidget();
  });

  container.querySelector('#nd-music-next').addEventListener('click', () => {
    state.activeTrackIndex = (state.activeTrackIndex + 1) % state.tracks.length;
    state.progress = 0;
    renderMusicWidget();
  });
}

// 6. Stocks Widget Renderer
function renderStocksWidget() {
  const container = document.getElementById('showcase-interactive-container');
  if (!container) return;

  const state = showState.stocks;

  let listHTML = '';
  state.indices.forEach(s => {
    const isPositive = s.change >= 0;
    listHTML += `
      <div class="nd-stock-index-card ${state.activeSymbol === s.symbol ? 'active' : ''}" data-symbol="${s.symbol}">
        <div class="nd-stock-index-left">
          <span class="nd-stock-symbol-badge">${escapeHTML(s.symbol)}</span>
          <span class="nd-stock-index-name">${escapeHTML(s.name)}</span>
        </div>
        
        <div class="nd-stock-sparkline-box">
          <svg viewBox="0 0 50 20" width="100%" height="100%">
            <path d="${s.sparkline}" fill="none" stroke="${isPositive ? '#799139' : '#b2504a'}" stroke-width="1.5" />
          </svg>
        </div>
        
        <div class="nd-stock-index-metrics">
          <div class="nd-stock-metric-col">
            <div class="nd-stock-metric-row"><span class="nd-stock-metric-label">O</span> <span class="nd-stock-metric-val">$${s.open.toFixed(2)}</span></div>
            <div class="nd-stock-metric-row"><span class="nd-stock-metric-label">H</span> <span class="nd-stock-metric-val">$${s.high.toFixed(2)}</span></div>
            <div class="nd-stock-metric-row"><span class="nd-stock-metric-label">L</span> <span class="nd-stock-metric-val">$${s.low.toFixed(2)}</span></div>
            <div class="nd-stock-metric-row"><span class="nd-stock-metric-label">V</span> <span class="nd-stock-metric-val">${s.vol}</span></div>
          </div>
          <div class="nd-stock-metric-col">
            <div class="nd-stock-metric-row"><span class="nd-stock-metric-label">MC</span> <span class="nd-stock-metric-val">--</span></div>
            <div class="nd-stock-metric-row"><span class="nd-stock-metric-label">PE</span> <span class="nd-stock-metric-val">--</span></div>
            <div class="nd-stock-metric-row"><span class="nd-stock-metric-label">EP</span> <span class="nd-stock-metric-val">--</span></div>
          </div>
        </div>
        
        <div class="nd-stock-index-right-wrapper">
          <div class="nd-stock-index-right">
            <span class="nd-stock-index-price" id="price-${s.symbol.replace('^', '\\^')}">$${s.price.toFixed(2)}</span>
            <span class="nd-stock-index-change ${isPositive ? 'positive' : 'negative'}">
              ${isPositive ? '+' : ''}${s.change.toFixed(2)} (${isPositive ? '+' : ''}${s.changePercent.toFixed(2)}%)
            </span>
          </div>
          <i class="fa-solid fa-bookmark nd-stock-bookmark ${s.bookmarked ? 'active' : ''}" data-id="${s.symbol}"></i>
        </div>
      </div>
    `;
  });

  container.innerHTML = `
    <div class="nd-widget nd-stocks-widget">
      ${getWidgetHeaderHTML('stocks')}
      <div class="nd-stocks-top-row">
        <div class="nd-segmented-control" style="margin-bottom: 0;">
          <button class="nd-segment-btn">US</button>
          <button class="nd-segment-btn active">World Indices</button>
          <button class="nd-segment-btn">Semi Conductor</button>
          <button class="nd-segment-btn">Commodity</button>
          <button class="nd-segment-btn">Data Center</button>
          <button class="nd-segment-btn">Crypto</button>
        </div>
      </div>
      <div class="nd-stocks-list">
        ${listHTML}
      </div>
    </div>
  `;

  if (!state.tickerInterval) {
    state.tickerInterval = setInterval(() => {
      state.indices.forEach(s => {
        const changeVal = (Math.random() - 0.48) * 4;
        s.price += changeVal;
        s.change += changeVal;
        s.changePercent = (s.change / s.open) * 100;
        if (s.price > s.high) s.high = s.price;
        if (s.price < s.low) s.low = s.price;

        const priceEl = container.querySelector(`#price-${s.symbol.replace('^', '\\^')}`);
        if (priceEl) {
          priceEl.textContent = `$${s.price.toFixed(2)}`;
          priceEl.style.color = changeVal >= 0 ? '#30d158' : '#ff453a';
          setTimeout(() => {
            priceEl.style.color = '';
          }, 600);
        }
      });
      renderStocksWidget();
    }, 4000);
  }

  container.querySelectorAll('.nd-stock-index-card').forEach(card => {
    card.addEventListener('click', (e) => {
      if (e.target.closest('.nd-stock-bookmark')) return;
      state.activeSymbol = card.getAttribute('data-symbol');
      renderStocksWidget();
    });
  });

  container.querySelectorAll('.nd-stock-bookmark').forEach(bm => {
    bm.addEventListener('click', (e) => {
      e.stopPropagation();
      const id = bm.getAttribute('data-id');
      const item = state.indices.find(s => s.symbol === id);
      if (item) {
        item.bookmarked = !item.bookmarked;
        renderStocksWidget();
      }
    });
  });
}

// 7. Live Notch Status Bar Widget Renderer
function renderNotchBarWidget() {
  const container = document.getElementById('showcase-interactive-container');
  if (!container) return;

  const state = showState.notchbar;

  const formatTimer = (secs) => {
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m < 10 ? '0' : ''}${m}:${s < 10 ? '0' : ''}${s}`;
  };

  let leftIndicators = '<span>9:41 AM</span>';
  let rightIndicators = `
    <i class="fa-solid fa-wifi" style="margin-right:4px;"></i>
    <i class="fa-solid fa-battery-three-quarters"></i>
  `;
  
  let adjacentLeft = '';
  let adjacentRight = '';
  
  let bezelNotchWidth = '80px';
  if (state.notchSize === 'small') bezelNotchWidth = '54px';
  if (state.notchSize === 'medium') bezelNotchWidth = '120px';
  if (state.notchSize === 'large') bezelNotchWidth = '160px';
  if (state.notchSize === 'none') bezelNotchWidth = '0px';

  if (state.mode === 'stocks') {
    adjacentLeft = `
      <span style="color: rgba(255,255,255,0.5); font-weight: 500;">^GSPC</span>
      <span style="color: #fff; font-weight: 700; font-family: var(--font-mono);">$7409.23</span>
    `;
    adjacentRight = `
      <span style="color: #30d158; font-weight: 700; font-family: var(--font-mono);">+43.77 (+0.59%)</span>
    `;
  } else if (state.mode === 'timer') {
    adjacentLeft = `
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="width: 12px; height: 12px; display: inline-block; vertical-align: middle; color: rgba(255,255,255,0.95);">
        <circle cx="12" cy="13" r="7" />
        <polyline points="12 9 12 13 15 13" />
        <line x1="12" y1="2" x2="12" y2="4" />
        <line x1="9" y1="2" x2="15" y2="2" />
      </svg>
    `;
    const timerColor = state.timerSeconds < 10 ? '#ff453a' : '#fff';
    adjacentRight = `
      <span style="color: ${timerColor}; font-weight: 700; font-family: var(--font-mono);">${formatTimer(state.timerSeconds)}</span>
    `;
  }

  container.innerHTML = `
    <div class="nd-widget nd-notchbar-widget">
      ${getWidgetHeaderHTML('notchbar')}
      <div class="nd-bezel-preview-wrapper" style="border-width: ${state.notchSize === 'none' ? '6px 6px 0 6px' : '10px 10px 0 10px'}">
        <div class="nd-bezel-wallpaper wp-${state.wallpaper}"></div>
        <div class="nd-bezel-top-bar">
          <div class="nd-bezel-left-items">${leftIndicators}</div>
          
          <div class="nd-bezel-center-group">
            <div class="nd-bezel-adjacent-left">${adjacentLeft}</div>
            <div class="nd-bezel-notch" style="width: ${bezelNotchWidth}; height: ${state.notchSize === 'none' ? '0px' : '18px'}">
              <div class="nd-bezel-camera"></div>
            </div>
            <div class="nd-bezel-adjacent-right">${adjacentRight}</div>
          </div>
          
          <div class="nd-bezel-right-items">${rightIndicators}</div>
        </div>
      </div>
      
      <div class="nd-notchbar-controls">
        <div class="nd-notchbar-col">
          <span class="nd-notchbar-col-label">Notch Integration</span>
          <div class="nd-notchbar-btn-group">
            <button class="nd-notchbar-btn ${state.mode === 'default' ? 'active' : ''}" data-mode="default">Default</button>
            <button class="nd-notchbar-btn ${state.mode === 'stocks' ? 'active' : ''}" data-mode="stocks">Ticker</button>
            <button class="nd-notchbar-btn ${state.mode === 'timer' ? 'active' : ''}" data-mode="timer">Timer</button>
          </div>
        </div>
        
        <div class="nd-notchbar-col">
          <span class="nd-notchbar-col-label">Bezel Type</span>
          <div class="nd-notchbar-btn-group">
            <button class="nd-notchbar-btn ${state.notchSize === 'small' ? 'active' : ''}" data-size="small">14" MBP</button>
            <button class="nd-notchbar-btn ${state.notchSize === 'medium' ? 'active' : ''}" data-size="medium">16" MBP</button>
            <button class="nd-notchbar-btn ${state.notchSize === 'none' ? 'active' : ''}" data-size="none">Air</button>
          </div>
        </div>

        <div class="nd-notchbar-col" style="flex: 0.8;">
          <span class="nd-notchbar-col-label">Wallpaper</span>
          <div style="display: flex; gap: 8px; align-items: center; padding-top: 4px;">
            <div class="nd-notchbar-color-dot wp-monterey-pink ${state.wallpaper === 'monterey-pink' ? 'active' : ''}" data-wp="monterey-pink"></div>
            <div class="nd-notchbar-color-dot wp-sonoma-orange ${state.wallpaper === 'sonoma-orange' ? 'active' : ''}" data-wp="sonoma-orange"></div>
            <div class="nd-notchbar-color-dot wp-space-gray ${state.wallpaper === 'space-gray' ? 'active' : ''}" data-wp="space-gray"></div>
          </div>
        </div>
      </div>
    </div>
  `;

  container.querySelectorAll('[data-mode]').forEach(btn => {
    btn.addEventListener('click', () => {
      state.mode = btn.getAttribute('data-mode');
      
      if (state.mode === 'timer') {
        state.timerRunning = true;
        if (!state.timerInterval) {
          state.timerSeconds = 55;
          state.timerInterval = setInterval(() => {
            if (state.timerRunning && state.timerSeconds > 0) {
              state.timerSeconds--;
              renderNotchBarWidget();
            }
          }, 1000);
        }
      } else {
        state.timerRunning = false;
        clearInterval(state.timerInterval);
        state.timerInterval = null;
      }

      renderNotchBarWidget();
    });
  });

  container.querySelectorAll('[data-size]').forEach(btn => {
    btn.addEventListener('click', () => {
      state.notchSize = btn.getAttribute('data-size');
      renderNotchBarWidget();
    });
  });

  container.querySelectorAll('[data-wp]').forEach(dot => {
    dot.addEventListener('click', () => {
      state.wallpaper = dot.getAttribute('data-wp');
      renderNotchBarWidget();
    });
  });
}

function initShowcaseTabs() {
  const tabs = document.querySelectorAll('.tab-btn');
  const previewTitle = document.getElementById('preview-title');
  const macbookFrame = document.querySelector('.macbook-frame');
  const interactiveContainer = document.getElementById('showcase-interactive-container');

  const tabData = {
    sports: {
      title: 'Sports Live Updates',
      render: () => {
        showState.sports.matchDetailsId = null;
        renderSportsWidget();
      }
    },
    'match-stats': {
      title: 'Match Statistics',
      render: () => {
        showState.sports.matchDetailsId = 's5'; // Default to Mexico vs Czechia
        renderSportsWidget();
      }
    },
    calendar: {
      title: 'Calendar & Meeting Agenda',
      render: renderCalendarWidget
    },
    clipboard: {
      title: 'Clipboard Manager',
      render: renderClipboardWidget
    },
    todo: {
      title: 'Quick To-Do Tasks',
      render: renderTodoWidget
    },
    music: {
      title: 'System Media Controller',
      render: renderMusicWidget
    },
    stocks: {
      title: 'Stocks & Indices Tracker',
      render: renderStocksWidget
    },
    notchbar: {
      title: 'Live Notch Status Bar',
      render: renderNotchBarWidget
    }
  };

  if (interactiveContainer) {
    // Add event delegation for mockup header navigation
    interactiveContainer.addEventListener('click', (e) => {
      const tabNav = e.target.closest('[data-tab-nav]');
      if (tabNav) {
        const tabId = tabNav.getAttribute('data-tab-nav');
        const tabBtn = document.getElementById('tab-' + tabId);
        if (tabBtn) {
          tabBtn.click();
        }
      }
    });

    renderSportsWidget();
  }

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const tabId = tab.getAttribute('data-tab');
      if (!tabId || !tabData[tabId]) return;

      tabs.forEach(btn => btn.classList.remove('active'));
      tab.classList.add('active');

      if (macbookFrame) {
        macbookFrame.style.transform = 'scale(0.985) translateY(2px)';
        setTimeout(() => {
          macbookFrame.style.transform = 'scale(1) translateY(0)';
        }, 150);
      }

      if (previewTitle) {
        previewTitle.textContent = tabData[tabId].title;
      }

      // Sync with top notch interactive widget
      if (typeof window.triggerNotchTab === 'function') {
        if (tabId === 'sports' || tabId === 'match-stats') {
          window.triggerNotchTab('sports');
        } else if (tabId === 'music') {
          window.triggerNotchTab('music');
        } else if (tabId === 'stocks') {
          window.triggerNotchTab('stocks');
        }
      }

      if (interactiveContainer) {
        interactiveContainer.style.opacity = '0';
        interactiveContainer.style.transform = 'scale(0.99) translateY(2px)';
        interactiveContainer.style.transition = 'opacity 0.15s ease, transform 0.15s ease';
        
        setTimeout(() => {
          if (tabId !== 'music' && showState.music.interval) {
            clearInterval(showState.music.interval);
            showState.music.interval = null;
            showState.music.isPlaying = false;
          }
          if (tabId !== 'stocks' && showState.stocks.tickerInterval) {
            clearInterval(showState.stocks.tickerInterval);
            showState.stocks.tickerInterval = null;
          }
          if (tabId !== 'notchbar' && showState.notchbar.timerInterval) {
            clearInterval(showState.notchbar.timerInterval);
            showState.notchbar.timerInterval = null;
            showState.notchbar.timerRunning = false;
          }

          tabData[tabId].render();
          
          interactiveContainer.style.opacity = '1';
          interactiveContainer.style.transform = 'scale(1) translateY(0)';
        }, 150);
      }
    });
  });
}

/**
 * 2. Top Page Notch Interactivity
 * Simulates actions within the floating notch (play/pause and live score updates)
 */
function initInteractiveNotch() {
  const pageNotch = document.getElementById('page-notch');
  if (!pageNotch) return;

  const liveIndicatorText = document.querySelector('.indicator-text');
  const pulseDot = document.querySelector('.pulse-dot');

  // Shared state structures
  const musicState = {
    isPlaying: true,
    progressPercent: 45,
    trackDuration: 243, // M83 Midnight City duration: 4:03
    title: 'Midnight City',
    artist: 'M83',
    album: "Hurry Up, We're Dreaming"
  };

  const sportsState = {
    isPlaying: true,
    elapsedMinutes: 59,
    scoreA: 0,
    scoreB: 0,
    isStarred: false
  };

  const stocksList = [
    { symbol: '^DJI', name: 'Dow Jones', price: 52142.21, change: 475.37, changePercent: 0.92, open: 51701.37, high: 52247.23, low: 51701.37 },
    { symbol: '^IXIC', name: 'NASDAQ', price: 25750.10, change: 163.06, changePercent: 0.64, open: 25638.91, high: 25827.33, low: 25634.08 },
    { symbol: '^GSPC', name: 'S&P 500', price: 7410.74, change: 45.28, changePercent: 0.61, open: 7386.25, high: 7424.92, low: 7384.21 }
  ];
  const stocksState = {
    isPlaying: true,
    activeIndex: 1 // NASDAQ by default
  };

  let activeTab = 'music';

  // Toggle active widgets helper
  function switchTab(tabId) {
    activeTab = tabId;
    
    // Hide all notch widget containers
    document.getElementById('notch-music-widget').style.display = 'none';
    document.getElementById('notch-sports-widget').style.display = 'none';
    document.getElementById('notch-stocks-widget').style.display = 'none';
    
    // Show selected notch widget container
    if (tabId === 'sports') {
      document.getElementById('notch-sports-widget').style.display = 'flex';
    } else if (tabId === 'music') {
      document.getElementById('notch-music-widget').style.display = 'flex';
    } else if (tabId === 'stocks') {
      document.getElementById('notch-stocks-widget').style.display = 'flex';
    }

    // Update active class on switch-btn elements in all widget headers
    document.querySelectorAll('.notch-widget-switcher .switch-btn').forEach(btn => {
      if (btn.getAttribute('data-notch-tab') === tabId) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }
    });

    syncCollapsedContent();
  }

  function formatTime(secs) {
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m}:${s < 10 ? '0' : ''}${s}`;
  }

  // Update collapsed view
  function syncCollapsedContent() {
    if (!liveIndicatorText || !pulseDot) return;

    if (activeTab === 'sports') {
      pulseDot.style.backgroundColor = '#30d158';
      pulseDot.style.boxShadow = '0 0 8px #30d158';
      liveIndicatorText.textContent = `COD ${sportsState.scoreA} - ${sportsState.scoreB} COL ${sportsState.elapsedMinutes}'`;
    } else if (activeTab === 'music') {
      pulseDot.style.backgroundColor = '#d946ef';
      pulseDot.style.boxShadow = '0 0 8px #d946ef';
      liveIndicatorText.textContent = `${musicState.title} — ${musicState.artist}`;
    } else if (activeTab === 'stocks') {
      const activeStock = stocksList[stocksState.activeIndex];
      const isPositive = activeStock.change >= 0;
      pulseDot.style.backgroundColor = isPositive ? '#30d158' : '#ff453a';
      pulseDot.style.boxShadow = `0 0 8px ${isPositive ? '#30d158' : '#ff453a'}`;
      liveIndicatorText.textContent = `${activeStock.symbol} $${activeStock.price.toFixed(2)} (${isPositive ? '+' : ''}${activeStock.changePercent.toFixed(2)}%)`;
    }
  }

  // Bind Switcher Buttons
  document.querySelectorAll('.notch-widget-switcher .switch-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const tabId = btn.getAttribute('data-notch-tab');
      switchTab(tabId);
    });
  });

  // Expose global click dispatcher for showcase sync
  window.triggerNotchTab = function(tabId) {
    if (['sports', 'music', 'stocks'].includes(tabId)) {
      switchTab(tabId);
    }
  };

  // --- Music Widget Simulation ---
  const musicContainer = document.getElementById('notch-music-widget');
  const musicProgressFill = musicContainer.querySelector('.progress-fill');
  const musicTimeElapsed = musicContainer.querySelector('.progress-time span:first-child');
  const musicTimeRemaining = musicContainer.querySelector('.progress-time span:last-child');
  const musicPlayBtn = musicContainer.querySelector('.play-btn');

  setInterval(() => {
    if (musicState.isPlaying) {
      musicState.progressPercent += 0.2;
      if (musicState.progressPercent >= 100) {
        musicState.progressPercent = 0;
      }
      if (musicProgressFill) {
        musicProgressFill.style.width = `${musicState.progressPercent}%`;
      }
      const elapsed = (musicState.progressPercent / 100) * musicState.trackDuration;
      const remaining = musicState.trackDuration - elapsed;
      if (musicTimeElapsed) musicTimeElapsed.textContent = formatTime(elapsed);
      if (musicTimeRemaining) musicTimeRemaining.textContent = `-${formatTime(remaining)}`;
      syncCollapsedContent();
    }
  }, 1000);

  if (musicPlayBtn) {
    musicPlayBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      musicState.isPlaying = !musicState.isPlaying;
      const icon = musicPlayBtn.querySelector('i');
      if (icon) {
        icon.className = musicState.isPlaying ? 'fa-solid fa-pause' : 'fa-solid fa-play';
      }
    });
  }

  const musicPrevBtn = musicContainer.querySelector('.prev-btn');
  const musicNextBtn = musicContainer.querySelector('.next-btn');
  if (musicPrevBtn) {
    musicPrevBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      musicState.progressPercent = 0;
    });
  }
  if (musicNextBtn) {
    musicNextBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      musicState.progressPercent = 0;
    });
  }

  // --- Sports Widget Simulation ---
  const sportsContainer = document.getElementById('notch-sports-widget');
  const sportsScoreText = sportsContainer.querySelector('.match-score');
  const sportsTimeText = sportsContainer.querySelector('.match-time');



  function renderNotchSportsUI() {
    if (sportsScoreText) {
      sportsScoreText.textContent = `${sportsState.scoreA} - ${sportsState.scoreB}`;
    }
    if (sportsTimeText) {
      sportsTimeText.innerHTML = `<span class="live-dot text-green">●</span> ${sportsState.elapsedMinutes}'`;
    }
    syncCollapsedContent();
  }

  setInterval(() => {
    if (sportsState.isPlaying) {
      sportsState.elapsedMinutes++;
      if (sportsState.elapsedMinutes > 90) sportsState.elapsedMinutes = 0;
      
      // Randomly score a goal
      if (Math.random() > 0.98) {
        if (Math.random() > 0.5) sportsState.scoreA++;
        else sportsState.scoreB++;
      }
      renderNotchSportsUI();
    }
  }, 1000);

  // --- Stocks Widget Simulation ---
  const stocksContainer = document.getElementById('notch-stocks-widget');
  const stocksProgressFill = stocksContainer.querySelector('.stocks-progress-fill');
  const stocksNameText = stocksContainer.querySelector('.stock-name');
  const stocksChangeText = stocksContainer.querySelector('.stock-change');
  const stocksPriceTextLarge = stocksContainer.querySelector('.stock-price-large');
  const stocksLowText = stocksContainer.querySelector('.stock-low');
  const stocksHighText = stocksContainer.querySelector('.stock-high');

  function renderNotchStocksUI() {
    const activeStock = stocksList[stocksState.activeIndex];
    const isPositive = activeStock.change >= 0;

    if (stocksNameText) stocksNameText.textContent = `${activeStock.name} (${activeStock.symbol})`;
    
    if (stocksChangeText) {
      stocksChangeText.textContent = `${isPositive ? '+' : ''}${activeStock.change.toFixed(2)} (${isPositive ? '+' : ''}${activeStock.changePercent.toFixed(2)}%)`;
      stocksChangeText.className = `stock-change ${isPositive ? 'text-green' : 'text-red'}`;
    }

    if (stocksPriceTextLarge) {
      stocksPriceTextLarge.textContent = `$${activeStock.price.toFixed(2)}`;
    }

    if (stocksLowText) stocksLowText.textContent = `Low: $${activeStock.low.toFixed(2)}`;
    if (stocksHighText) stocksHighText.textContent = `High: $${activeStock.high.toFixed(2)}`;

    // Range slider progress fill
    const range = activeStock.high - activeStock.low;
    const currentPos = activeStock.price - activeStock.low;
    const percent = range > 0 ? (currentPos / range) * 100 : 50;
    if (stocksProgressFill) {
      stocksProgressFill.style.width = `${Math.max(0, Math.min(100, percent))}%`;
    }

    syncCollapsedContent();
  }

  setInterval(() => {
    if (stocksState.isPlaying) {
      // Simulate live market fluctuation
      stocksList.forEach((s, idx) => {
        const changeVal = (Math.random() - 0.48) * 3;
        s.price += changeVal;
        s.change += changeVal;
        s.changePercent = (s.change / s.open) * 100;
        if (s.price > s.high) s.high = s.price;
        if (s.price < s.low) s.low = s.price;
      });

      renderNotchStocksUI();
    }
  }, 3000);


  // Initial Sync
  switchTab('music');
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
          window.location.href = 'https://github.com/rohanrony/notchdock/releases/latest/notchdock.dmg';
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

/**
 * Rotates the hero section preview GIFs sequentially
 */
/**
 * 5. Unified Auto Rotation
 * Automatically rotates the Hero GIF, the top notch interactive widgets,
 * and the showcase section every 5 seconds synchronously.
 */
function initUnifiedAutoRotation() {
  const heroImg = document.getElementById('hero-preview-img');
  
  // The tabs we want to cycle through
  const tabs = ['tab-music', 'tab-sports', 'tab-stocks'];
  
  // The GIFs that correspond to each tab
  const gifs = {
    'tab-music': '/assets/hero.gif',
    'tab-sports': '/assets/SportsModule.gif',
    'tab-stocks': '/assets/StocksModule.gif'
  };

  // Preload the next GIFs to avoid loading delays
  Object.values(gifs).forEach(src => {
    const img = new Image();
    img.src = src;
  });

  let currentTabIndex = 0;
  let isHovered = false;

  const notch = document.getElementById('page-notch');
  if (notch) {
    notch.addEventListener('mouseenter', () => isHovered = true);
    notch.addEventListener('mouseleave', () => isHovered = false);
  }

  setInterval(() => {
    // Pause auto-rotation if the user is interacting with the notch
    if (isHovered) return;

    currentTabIndex = (currentTabIndex + 1) % tabs.length;
    const tabId = tabs[currentTabIndex];
    
    // 1. Trigger the showcase tab (which inherently syncs the top notch)
    const tabToClick = document.getElementById(tabId);
    if (tabToClick) {
      tabToClick.click();
    }
    
    // 2. Sync the Hero GIF
    if (heroImg) {
      heroImg.style.opacity = '0';
      setTimeout(() => {
        heroImg.src = gifs[tabId];
        let loaded = false;
        const fadeIn = () => {
          if (loaded) return;
          loaded = true;
          heroImg.style.opacity = '1';
        };
        heroImg.onload = fadeIn;
        setTimeout(fadeIn, 300);
      }, 500);
    }
  }, 5000); // 5 seconds
}
