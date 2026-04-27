const GEMINI_API_BASE = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

// ── ✏️  EASY API KEY SETUP ────────────────────────────────────────────
// Replace the string below with your Gemini API key from https://aistudio.google.com/apikey
// The app will use this key automatically without needing to type it in the UI.
const HARDCODED_API_KEY = 'REPLACED_LEAKED_KEY';
// ─────────────────────────────────────────────────────────────────────

let apiKey = localStorage.getItem('allocatai_key') || (HARDCODED_API_KEY !== 'YOUR_GEMINI_API_KEY_HERE' ? HARDCODED_API_KEY : '');

// ── DOM refs ──────────────────────────────────────────────────────────
const apiKeyInput = document.getElementById('apiKeyInput');
const saveApiKey = document.getElementById('saveApiKey');
const suppliesInput = document.getElementById('suppliesInput');
const demandsInput = document.getElementById('demandsInput');
const allocateBtn = document.getElementById('allocateBtn');
const loadSampleData = document.getElementById('loadSampleData');

const resultsEmpty = document.getElementById('resultsEmpty');
const skeletonLoader = document.getElementById('skeletonLoader');
const resultsContent = document.getElementById('resultsContent');
const matchContent = document.getElementById('matchContent');
const logisticsContent = document.getElementById('logisticsContent');
const impactContent = document.getElementById('impactContent');

const btnText = document.getElementById('btnText');
const btnLoader = document.getElementById('btnLoader');

const statusIndicator = document.getElementById('statusIndicator');
const statusLabel = document.getElementById('statusLabel');
const pageLoader = document.getElementById('pageLoader');


// ── Page entry animation ───────────────────────────────────────────────
window.addEventListener('load', () => {
    // Let the loader bar animation finish (~1.4s), then fade out
    setTimeout(() => pageLoader.classList.add('done'), 1600);
});


// ── API Key initialisation ─────────────────────────────────────────────
if (apiKey) {
    apiKeyInput.value = apiKey;
    markKeySaved();
}

saveApiKey.addEventListener('click', () => {
    const val = apiKeyInput.value.trim();
    if (!val) return;
    apiKey = val;
    localStorage.setItem('allocatai_key', val);
    markKeySaved();
    validateInputs();
});

function markKeySaved() {
    saveApiKey.textContent = '✓ Connected';
    saveApiKey.classList.remove('btn-outline');
    saveApiKey.classList.add('btn-primary');
    saveApiKey.style.width = 'auto';
}


// ── Inputs ─────────────────────────────────────────────────────────────
suppliesInput.addEventListener('input', validateInputs);
demandsInput.addEventListener('input', validateInputs);

loadSampleData.addEventListener('click', () => {
    // Animate textarea fill
    typeInto(suppliesInput,
        `- 500 boxed meals (expires in 2 days) at Greenfield Catering\n- 4 idle cargo vans at City Transit Hub\n- 50 winter coats donated by Community Center`
    );
    typeInto(demandsInput,
        `- Downtown Shelter: Needs food for 250 people tonight, lacks transport.\n- Westside Orphanage: Needs winter clothing for 40 children.\n- South District Clinic: Food for 100 night shift staff.`
        , 20);
    setTimeout(validateInputs, 80);
});

/** Simulates typing text into a textarea with a subtle reveal animation */
function typeInto(el, text, delay = 0) {
    el.value = '';
    const chars = text.split('');
    let i = 0;
    setTimeout(() => {
        const id = setInterval(() => {
            el.value += chars[i++];
            if (i >= chars.length) clearInterval(id);
        }, 6);
    }, delay);
}

function validateInputs() {
    const hasKey = apiKey.length > 0;
    const hasData = suppliesInput.value.trim().length > 10 && demandsInput.value.trim().length > 10;
    allocateBtn.disabled = !(hasKey && hasData);
}


// ── Allocation ─────────────────────────────────────────────────────────
allocateBtn.addEventListener('click', runAllocation);

async function runAllocation() {
    setThinkingState(true);

    const prompt = `
You are an expert AI logistics and resource allocation engine solving the "Smart Resource Allocation" Open Innovation Challenge.
Your goal is to match "Available Resources (Supply)" with "Current Demands (Needs)" optimally, prioritizing urgency and minimizing waste.

Here is the data:
[AVAILABLE RESOURCES]
${suppliesInput.value.trim()}

[CURRENT DEMANDS]
${demandsInput.value.trim()}

Please analyze this data and return the output EXACTLY matching these three markdown sections:

### 🎯 Priority Matches
(Detail exactly which supply goes to which demand. Bullet points. Explain the rationale briefly based on urgency.)

### 🚚 Logistics & Routing
(Provide actionable recommendations on how to physically move the goods. Account for any idle transport mentioned in resources.)

### 📈 Projected Impact
(Summarize the impact: e.g. estimated number of people helped, amount of waste prevented. Keep it metric-focused).

Do not include any other top-level headers.
  `.trim();

    try {
        const rawMarkdown = await fetchGemini(prompt);
        renderResults(rawMarkdown);
        setStatus('done', 'Plan Generated');
    } catch (err) {
        setStatus('ready', 'Ready');
        showToast(`❌ ${err.message}`);
        console.error(err);
    } finally {
        setThinkingState(false);
    }
}

async function fetchGemini(prompt) {
    const res = await fetch(`${GEMINI_API_BASE}?key=${apiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: { temperature: 0.2 }
        })
    });

    if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.error?.message || `HTTP ${res.status}`);
    }

    const data = await res.json();
    return data.candidates[0]?.content?.parts[0]?.text || '';
}


// ── Render results ─────────────────────────────────────────────────────
function renderResults(markdown) {
    const matchesSection = extractSection(markdown, '### 🎯 Priority Matches', '### 🚚 Logistics');
    const logisticsSection = extractSection(markdown, '### 🚚 Logistics', '### 📈 Projected');
    const impactSection = extractSection(markdown, '### 📈 Projected', null);

    matchContent.innerHTML = marked.parse(matchesSection || 'No matches generated.');
    logisticsContent.innerHTML = marked.parse(logisticsSection || 'No logistics generated.');
    impactContent.innerHTML = marked.parse(impactSection || 'No impact generated.');

    resultsEmpty.classList.add('hidden');
    skeletonLoader.classList.add('hidden');
    resultsContent.classList.remove('hidden');

    // Staggered card reveal
    const cards = resultsContent.querySelectorAll('.result-card');
    cards.forEach((card, i) => {
        card.classList.remove('card-visible');
        setTimeout(() => card.classList.add('card-visible'), i * 140);
    });
}

function extractSection(text, startSign, endSign) {
    const startMatch = text.indexOf(startSign) > -1 ? startSign : startSign.substring(0, 10);
    let startIdx = text.indexOf(startMatch);
    if (startIdx === -1) return '';
    startIdx += startMatch.length;

    let endIdx = endSign ? text.indexOf(endSign.substring(0, 10), startIdx) : text.length;
    if (endIdx === -1) endIdx = text.length;
    return text.substring(startIdx, endIdx).trim();
}


// ── UI State helpers ───────────────────────────────────────────────────
function setThinkingState(on) {
    // Button
    allocateBtn.disabled = on;
    btnText.classList.toggle('hidden', on);
    btnLoader.classList.toggle('hidden', !on);

    if (on) {
        // Hide previous results, show skeleton
        resultsContent.classList.add('hidden');
        resultsEmpty.classList.add('hidden');
        skeletonLoader.classList.remove('hidden');
        setStatus('thinking', 'AI is thinking…');
    } else {
        skeletonLoader.classList.add('hidden');
        if (!on) validateInputs();
    }
}

function setStatus(state, label) {
    statusIndicator.className = 'status-indicator ' + state;
    statusLabel.textContent = label;
}


// ── Toast notification ─────────────────────────────────────────────────
function showToast(msg) {
    const old = document.querySelector('.toast-notif');
    if (old) old.remove();

    const t = document.createElement('div');
    t.className = 'toast-notif';
    t.textContent = msg;
    t.style.cssText = `
    position:fixed; bottom:28px; right:28px; z-index:999;
    background:#1e293b; border:1px solid rgba(239,68,68,0.4);
    color:#f8fafc; padding:12px 20px; border-radius:10px;
    font-size:0.9rem; font-family:'Outfit',sans-serif;
    box-shadow:0 8px 32px rgba(0,0,0,0.5);
    animation: toastIn 0.3s cubic-bezier(0.22,1,0.36,1) both;
  `;

    const style = document.createElement('style');
    style.textContent = `
    @keyframes toastIn { from { opacity:0; transform:translateY(16px); } to { opacity:1; transform:translateY(0); } }
  `;
    document.head.appendChild(style);
    document.body.appendChild(t);
    setTimeout(() => { t.style.opacity = '0'; t.style.transition = 'opacity 0.3s'; setTimeout(() => t.remove(), 320); }, 3500);
}
