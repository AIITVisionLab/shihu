// Shared helpers for the split console pages.

const CONSOLE_THRESHOLD_STORAGE_KEY = 'console_thresholds_v1';
const DEFAULT_CONSOLE_THRESHOLDS = {
    temp: { min: 15, max: 35, unit: '°C' },
    hum: { min: 40, max: 70, unit: '%' },
    smoke: { min: 0, max: 200, unit: 'ppm' }
};

function cloneJson(value) {
    return JSON.parse(JSON.stringify(value));
}

function formatRelativeTime(date) {
    const diff = Math.floor((Date.now() - date.getTime()) / 1000);
    if (diff < 5) return '刚刚';
    if (diff < 60) return `${diff} 秒前`;
    if (diff < 3600) return `${Math.floor(diff / 60)} 分钟前`;
    if (diff < 86400) return `${Math.floor(diff / 3600)} 小时前`;
    return `${Math.floor(diff / 86400)} 天前`;
}

function formatDateTime(date = new Date()) {
    return new Intl.DateTimeFormat('zh-CN', {
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    }).format(date);
}

function setText(id, value, fallback) {
    const resolvedFallback = fallback || '--';
    const el = document.getElementById(id);
    if (el) {
        el.textContent = value != null && value !== '' ? value : resolvedFallback;
    }
}

function setTag(elementId, text, className) {
    const el = document.getElementById(elementId);
    if (el) {
        el.textContent = text;
        el.className = `tag ${className}`;
    }
}

function getConsoleThresholds() {
    try {
        const raw = localStorage.getItem(CONSOLE_THRESHOLD_STORAGE_KEY);
        if (!raw) {
            return cloneJson(DEFAULT_CONSOLE_THRESHOLDS);
        }

        const parsed = JSON.parse(raw);
        return {
            temp: {
                min: Number.isFinite(Number(parsed?.temp?.min)) ? Number(parsed.temp.min) : DEFAULT_CONSOLE_THRESHOLDS.temp.min,
                max: Number.isFinite(Number(parsed?.temp?.max)) ? Number(parsed.temp.max) : DEFAULT_CONSOLE_THRESHOLDS.temp.max,
                unit: DEFAULT_CONSOLE_THRESHOLDS.temp.unit
            },
            hum: {
                min: Number.isFinite(Number(parsed?.hum?.min)) ? Number(parsed.hum.min) : DEFAULT_CONSOLE_THRESHOLDS.hum.min,
                max: Number.isFinite(Number(parsed?.hum?.max)) ? Number(parsed.hum.max) : DEFAULT_CONSOLE_THRESHOLDS.hum.max,
                unit: DEFAULT_CONSOLE_THRESHOLDS.hum.unit
            },
            smoke: {
                min: Number.isFinite(Number(parsed?.smoke?.min)) ? Number(parsed.smoke.min) : DEFAULT_CONSOLE_THRESHOLDS.smoke.min,
                max: Number.isFinite(Number(parsed?.smoke?.max)) ? Number(parsed.smoke.max) : DEFAULT_CONSOLE_THRESHOLDS.smoke.max,
                unit: DEFAULT_CONSOLE_THRESHOLDS.smoke.unit
            }
        };
    } catch (error) {
        return cloneJson(DEFAULT_CONSOLE_THRESHOLDS);
    }
}

function saveConsoleThresholds(nextThresholds) {
    localStorage.setItem(CONSOLE_THRESHOLD_STORAGE_KEY, JSON.stringify(nextThresholds));
}

function extractApiPayload(payload) {
    if (payload == null) {
        return { code: null, msg: '', data: null };
    }
    if (Object.prototype.hasOwnProperty.call(payload, 'data')) {
        return {
            code: payload.code,
            msg: payload.msg || payload.message || '',
            data: payload.data
        };
    }
    return { code: null, msg: '', data: payload };
}

function isApiSuccess(payload) {
    const normalized = extractApiPayload(payload);
    return normalized.code == null || normalized.code === 0 || normalized.code === 200;
}

async function checkLogin() {
    try {
        const res = await fetch('/api/check-login', { cache: 'no-store' });
        const data = await res.json();
        if (!data.loggedIn) {
            window.location.href = '/login.html';
            return false;
        }

        const userEl = document.getElementById('current-user');
        if (userEl) {
            userEl.textContent = data.username || '--';
        }
        return true;
    } catch (error) {
        return true;
    }
}

async function logoutCurrentUser() {
    try {
        await fetch('/api/logout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
    } catch (error) {
        // Ignore logout transport failures and still return to the login page.
    } finally {
        window.location.href = '/login.html';
    }
}

document.addEventListener('DOMContentLoaded', function () {
    const logoutBtn = document.getElementById('logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', function (event) {
            event.preventDefault();
            logoutCurrentUser();
        });
    }
});
