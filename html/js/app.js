/* ==========================================
   QB SCOREBOARD — JS
   Developed by: Nerd Developer
   Website: https://nerd-developer.com
   ========================================== */

'use strict';

// -------- SVG ICONS --------
const ICONS = {
    house:   `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9.5L12 3l9 6.5V20a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9.5z"/><polyline points="9,21 9,12 15,12 15,21"/></svg>`,
    bank:    `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="3" y1="22" x2="21" y2="22"/><line x1="6" y1="18" x2="6" y2="11"/><line x1="10" y1="18" x2="10" y2="11"/><line x1="14" y1="18" x2="14" y2="11"/><line x1="18" y1="18" x2="18" y2="11"/><polygon points="12,2 20,7 4,7"/></svg>`,
    store:   `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>`,
    diamond: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12,2 22,9 18,21 6,21 2,9"/></svg>`,
    person:  `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>`,
    truck:   `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"/><polygon points="16,8 20,8 23,11 23,16 16,16 16,8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>`,
    money:   `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2"/><path d="M6 12h.01M18 12h.01"/></svg>`,
    star:    `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26"/></svg>`,
};

function getIcon(name) { return ICONS[name] || ICONS['star']; }

// -------- STATE --------
let config       = { serverName: 'SERVER', maxPlayers: 64, position: 'right' };
let visible      = false;
let clockInterval = null;
let eventsBuilt  = false;   // true once the event rows are in the DOM
let uiText       = { onlineText: 'Online', offlineText: 'Offline' };

// -------- DOM --------
const $scoreboard    = document.getElementById('scoreboard');
const $serverName    = document.getElementById('serverName');
const $playerCount   = document.getElementById('playerCount');
const $policeCount   = document.getElementById('policeCount');
const $emsCount      = document.getElementById('emsCount');
const $eventsList    = document.getElementById('eventsList');
const $headerTime    = document.getElementById('headerTime');
const $footerPlayers = document.getElementById('footerPlayers');
const $footerBarFill = document.getElementById('footerBarFill');
const $footerLeft    = document.getElementById('footerLeft');
const $labelPlayers  = document.getElementById('labelPlayers');
const $labelPolice   = document.getElementById('labelPolice');
const $labelEms      = document.getElementById('labelEms');
const $labelEvents   = document.getElementById('labelActiveEvents');

// ==========================================
// MESSAGE LISTENER
// ==========================================

window.addEventListener('message', ({ data: msg }) => {
    switch (msg.type) {
        case 'init':   applyConfig(msg.data); break;
        case 'open':   openBoard(msg.data);   break;
        case 'close':  closeBoard();          break;
        case 'update': updateData(msg.data);  break;
    }
});

// ==========================================
// CONFIG
// ==========================================

function applyConfig(cfg) {
    if (!cfg) return;
    config = Object.assign(config, cfg);

    $serverName.textContent = config.serverName || 'SERVER';

    $scoreboard.classList.remove('pos-right', 'pos-left', 'pos-right-mid', 'pos-left-mid');
    switch (config.position) {
        case 'left':
            $scoreboard.classList.add('pos-left');
            break;
        case 'leftMid':
            $scoreboard.classList.add('pos-left-mid');
            break;
        case 'rightMid':
            $scoreboard.classList.add('pos-right-mid');
            break;
        case 'right':
        default:
            $scoreboard.classList.add('pos-right');
            break;
    }

    const rtl = cfg.rtl === true || cfg.direction === 'rtl' || cfg.lang === 'ar';
    document.documentElement.classList.toggle('rtl', rtl);
    document.documentElement.dir = rtl ? 'rtl' : 'ltr';

    const ui = cfg.ui || {};
    uiText = Object.assign({ onlineText: 'Online', offlineText: 'Offline' }, ui);
    if ($labelPlayers && ui.playersLabel) $labelPlayers.textContent = ui.playersLabel;
    if ($labelPolice && ui.policeLabel) $labelPolice.textContent = ui.policeLabel;
    if ($labelEms && ui.emsLabel) $labelEms.textContent = ui.emsLabel;
    if ($labelEvents && ui.eventsTitle) $labelEvents.textContent = ui.eventsTitle;
    if ($footerLeft) {
        const t = ui.footerLeft != null && String(ui.footerLeft).trim() !== '' ? String(ui.footerLeft) : '';
        $footerLeft.textContent = t;
        const footerDot = document.querySelector('.footer-dot');
        if (footerDot) footerDot.style.display = t ? '' : 'none';
    }

    const root = document.documentElement;

    const nui = cfg.nui || {};
    if (typeof nui.PanelWidth === 'number') root.style.setProperty('--panel-w', `${Math.round(nui.PanelWidth)}px`);
    if (typeof nui.PanelMargin === 'number') root.style.setProperty('--panel-margin', `${Math.round(nui.PanelMargin)}px`);
    if (typeof nui.PanelYOffset === 'number') root.style.setProperty('--panel-yoff', `${Math.round(nui.PanelYOffset)}px`);

    const c    = config.colors || {};
    const map  = {
        Accent:          '--accent',
        BackgroundMain:  '--bg',
        BackgroundHeader:'--bg-header',
        TextPrimary:     '--text',
        TextSecondary:   '--text-sub',
        BorderColor:     '--border',
        ActiveColor:     '--active',
        InactiveColor:   '--inactive',
        PoliceColor:     '--police',
        EmsColor:        '--ems',
    };
    Object.entries(map).forEach(([key, css]) => {
        if (c[key]) root.style.setProperty(css, c[key]);
    });
}

// ==========================================
// OPEN / CLOSE
// ==========================================

function openBoard(data) {
    visible     = true;
    eventsBuilt = false;   // force full build on next render
    $scoreboard.classList.remove('hidden');
    $scoreboard.classList.add('visible');
    startClock();
    if (data) renderData(data, true);
}

function closeBoard() {
    visible = false;
    $scoreboard.classList.remove('visible');
    $scoreboard.classList.add('hidden');
    stopClock();
}

// ==========================================
// UPDATE — no re-animation
// ==========================================

function updateData(data) {
    if (visible && data) renderData(data, false);
}

// ==========================================
// RENDER
// ==========================================

function renderData(data, isFirstOpen) {
    const players = data.players || [];
    const police  = data.policeCount || 0;
    const ems     = data.emsCount    || 0;
    const events  = data.events      || [];

    // Players: keep count like before
    const maxPl = config.maxPlayers || 64;
    $playerCount.textContent  = `${players.length}/${maxPl}`;
    $footerPlayers.textContent = `${players.length} ${uiText.onlineText || 'online'}`;
    if ($footerBarFill) {
        const pct = maxPl > 0 ? Math.min(100, Math.round((players.length / maxPl) * 100)) : 0;
        $footerBarFill.style.width = `${pct}%`;
    }

    // Police/EMS: show status only (no numbers)
    const policeOnline = Number(police) > 0;
    const emsOnline    = Number(ems) > 0;

    // No text, only the dot indicator via CSS classes
    $policeCount.textContent = '';
    $emsCount.textContent    = '';

    $policeCount.classList.toggle('is-online', policeOnline);
    $policeCount.classList.toggle('is-offline', !policeOnline);
    $emsCount.classList.toggle('is-online', emsOnline);
    $emsCount.classList.toggle('is-offline', !emsOnline);

    renderEvents(events, isFirstOpen);
}

// ==========================================
// RENDER EVENTS
// Smart update: build DOM once, then only patch statuses
// ==========================================

function renderEvents(events, isFirstOpen) {
    if (!events || events.length === 0) {
        $eventsList.innerHTML = `<div style="text-align:center;padding:24px 0;color:var(--text-muted);font-size:11px;">No events configured</div>`;
        eventsBuilt = false;
        return;
    }

    // ---- FIRST BUILD (with animation) ----
    if (!eventsBuilt || isFirstOpen) {
        $eventsList.innerHTML = '';
        events.forEach((ev, i) => {
            const row = document.createElement('div');
            const readyClass = ev.ready ? ' is-ready' : ' is-not-ready';
            row.className      = `event-row${ev.active ? ' is-active' : ''}${readyClass}`;
            row.dataset.evId   = ev.id;
            row.style.animationDelay = `${i * 28}ms`;

            row.innerHTML = `
                <div class="event-icon-box">${getIcon(ev.icon || 'star')}</div>
                <span class="event-label">${escapeHtml(ev.label || 'Event')}</span>
                <div class="event-status"></div>
            `;
            $eventsList.appendChild(row);
        });
        eventsBuilt = true;
        return;
    }

    // ---- LIVE UPDATE (no animation, just patch classes) ----
    events.forEach((ev) => {
        const row = $eventsList.querySelector(`[data-ev-id="${ev.id}"]`);
        if (!row) return;

        const wasActive = row.classList.contains('is-active');
        if (wasActive !== ev.active) {
            if (ev.active) {
                row.classList.add('is-active');
            } else {
                row.classList.remove('is-active');
            }
        }

        const wasReady = row.classList.contains('is-ready');
        const isReady  = ev.ready === true;
        if (wasReady !== isReady) {
            row.classList.toggle('is-ready', isReady);
            row.classList.toggle('is-not-ready', !isReady);
        }
    });
}

// ==========================================
// CLOCK
// ==========================================

function startClock() {
    tick();
    clockInterval = setInterval(tick, 1000);
}

function stopClock() {
    if (clockInterval) { clearInterval(clockInterval); clockInterval = null; }
}

function tick() {
    const now = new Date();
    $headerTime.textContent =
        `${String(now.getHours()).padStart(2,'0')}:${String(now.getMinutes()).padStart(2,'0')}`;
}

// ==========================================
// UTILS
// ==========================================

function escapeHtml(str) {
    const d = document.createElement('div');
    d.appendChild(document.createTextNode(str));
    return d.innerHTML;
}

if (typeof GetParentResourceName === 'undefined') {
    window.GetParentResourceName = () => 'qb-scoreboard';
}

function nuiReady() {
    fetch(`https://${GetParentResourceName()}/nuiReady`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
    }).catch(() => {});
}

document.addEventListener('DOMContentLoaded', () => {
    // default positioning until init arrives
    $scoreboard.classList.add('pos-right-mid', 'hidden');
    nuiReady();
});
