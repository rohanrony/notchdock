const SESSION_KEY = 'notchdock_campaign_session_v1';
const SESSION_MS = 30 * 60 * 1000;
const slug = (value, fallback = '') => /^[a-z0-9_-]{1,64}$/i.test(value || '') ? value.toLowerCase() : fallback;
const pathOnly = (value) => {
  const path = (value || '/').split(/[?#]/)[0];
  return /^\/[a-z0-9/_-]*(?:\.html)?$/i.test(path) && path.length <= 160 ? path : '/';
};

export function landingAttribution(location, referrer = '') {
  const params = new URLSearchParams(location.search);
  let externalHost = '';
  try {
    const ref = new URL(referrer);
    if (ref.hostname !== location.hostname) externalHost = ref.hostname;
  } catch { /* No usable external referrer. */ }
  return {
    source: slug(params.get('utm_source') || params.get('ref'), externalHost ? slug(externalHost.replaceAll('.', '_'), 'referral') : 'direct'),
    medium: slug(params.get('utm_medium'), externalHost ? 'referral' : 'direct'),
    campaign: slug(params.get('utm_campaign')),
    placement: slug(params.get('utm_content')),
    landing: pathOnly(location.pathname),
  };
}

export function initCampaignAnalytics(win = window, doc = document) {
  const nav = win.navigator;
  if (nav.doNotTrack === '1' || nav.globalPrivacyControl === true) return;
  let memorySession;
  function session() {
    let saved = memorySession;
    try { saved = JSON.parse(win.sessionStorage.getItem(SESSION_KEY) || 'null'); } catch { /* Session storage may be disabled. */ }
    if (!saved || !Number.isSafeInteger(saved.started) || !/^[0-9a-f-]{36}$/i.test(saved.id || '') || Date.now() - saved.started >= SESSION_MS || saved.started > Date.now()) {
      const mobile = /Mobi|Android/i.test(nav.userAgent) || (/Mac/.test(nav.platform) && nav.maxTouchPoints > 1);
      saved = {
        id: win.crypto.randomUUID(), started: Date.now(),
        ...landingAttribution(win.location, doc.referrer),
        device: mobile ? 'mobile' : /Mac/.test(nav.platform) ? 'mac' : nav.platform ? 'other' : 'unknown',
      };
      memorySession = saved;
      try { win.sessionStorage.setItem(SESSION_KEY, JSON.stringify(saved)); } catch { /* In-memory fallback for this document only. */ }
    }
    return saved;
  }
  function send(event) {
    const current = session();
    // Navigation proceeds normally; never wait for analytics or fetch the installer.
    return win.fetch('/api/campaign-events', {
      method: 'POST', keepalive: true, credentials: 'omit',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...current, event }),
    }).then(response => response.ok).catch(() => false);
  }
  send('session');
  doc.addEventListener('click', event => {
    const link = event.target?.closest?.('a[href]');
    if (!link) return;
    let url;
    try { url = new URL(link.href, win.location.href); } catch { return; }
    if (url.hostname === 'github.com' && /^\/rohanrony\/notchdock\/releases\/(?:latest\/download|download\/[^/]+)\/notchdock(?:-[\d.]+)?\.dmg$/i.test(url.pathname)) {
      send('download');
    }
  }, { capture: true });
}
