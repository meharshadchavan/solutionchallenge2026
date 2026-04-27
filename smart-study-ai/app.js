// ──────────────────────────────────────────────────────────────
//  StudyAI – app.js  (Google Solution Challenge 2026)
//  Connects to Google Gemini API to generate study content
// ──────────────────────────────────────────────────────────────

const GEMINI_API_BASE = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

/* ── State ── */
let apiKey = localStorage.getItem('studyai_key') || '';

/* ── DOM refs ── */
const apiKeyInput  = document.getElementById('apiKeyInput');
const saveKeyBtn   = document.getElementById('saveApiKey');
const apiBanner    = document.getElementById('apiBanner');
const studyInput   = document.getElementById('studyInput');
const charCount    = document.getElementById('charCount');
const analyzeBtn   = document.getElementById('analyzeBtn');
const btnText      = document.getElementById('btnText');
const btnLoader    = document.getElementById('btnLoader');
const resultsEmpty = document.getElementById('resultsEmpty');
const resultsContent = document.getElementById('resultsContent');

const modeSummary  = document.getElementById('modeSummary');
const modeConcepts = document.getElementById('modeConcepts');
const modeQuiz     = document.getElementById('modeQuiz');

/* ── Init ── */
(function init() {
  if (apiKey) {
    apiBanner.classList.add('hidden');
    apiKeyInput.value = apiKey;
  }
  updateAnalyzeBtn();
})();

/* ── API Key Save ── */
saveKeyBtn.addEventListener('click', () => {
  const val = apiKeyInput.value.trim();
  if (!val) { showToast('⚠️ Please paste an API key first.'); return; }
  apiKey = val;
  localStorage.setItem('studyai_key', val);
  apiBanner.classList.add('hidden');
  showToast('✅ API key saved!');
  updateAnalyzeBtn();
});

/* ── Textarea character count ── */
studyInput.addEventListener('input', () => {
  charCount.textContent = `${studyInput.value.length} / 5000`;
  updateAnalyzeBtn();
});

/* ── Quick prompt buttons ── */
document.querySelectorAll('.quick-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    studyInput.value = btn.dataset.prompt;
    charCount.textContent = `${studyInput.value.length} / 5000`;
    updateAnalyzeBtn();
    studyInput.focus();
  });
});

/* ── Enable/Disable analyze button ── */
function updateAnalyzeBtn() {
  const hasInput = studyInput.value.trim().length >= 3;
  const hasKey   = Boolean(apiKey);
  analyzeBtn.disabled = !(hasInput && hasKey);
}

/* ── Main analyze action ── */
analyzeBtn.addEventListener('click', runAnalysis);

async function runAnalysis() {
  const text = studyInput.value.trim();
  if (!text) return;

  setLoading(true);

  const wantSummary  = modeSummary.checked;
  const wantConcepts = modeConcepts.checked;
  const wantQuiz     = modeQuiz.checked;

  if (!wantSummary && !wantConcepts && !wantQuiz) {
    showToast('⚠️ Select at least one output type!');
    setLoading(false);
    return;
  }

  // Build a structured prompt
  const sections = [];
  if (wantSummary)  sections.push(`1. SUMMARY: Write a concise 3–5 sentence summary of the content.`);
  if (wantConcepts) sections.push(`${wantSummary ? 2 : 1}. KEY_CONCEPTS: List 5 key concepts or terms as bullet points with one-line explanations.`);
  if (wantQuiz)     sections.push(`${([wantSummary, wantConcepts].filter(Boolean).length + 1)}. QUIZ: Create 3 multiple-choice questions (4 options each, mark correct answer with *). Format: Q: ... A) ... B) ... *C) ... D) ...`);

  const prompt = `You are an expert tutor. Analyze the following study material and provide exactly these sections:\n\n${sections.join('\n')}\n\nUse exactly the section labels (SUMMARY, KEY_CONCEPTS, QUIZ) as headers. Be educational and clear.\n\n--- STUDY MATERIAL ---\n${text}`;

  try {
    const response = await callGemini(prompt);
    renderResults(response, { wantSummary, wantConcepts, wantQuiz });
  } catch (err) {
    showToast(`❌ Error: ${err.message}`);
    console.error(err);
  } finally {
    setLoading(false);
  }
}

/* ── Call Gemini API ── */
async function callGemini(prompt) {
  const url = `${GEMINI_API_BASE}?key=${apiKey}`;
  const body = {
    contents: [{ parts: [{ text: prompt }] }],
    generationConfig: {
      temperature: 0.7,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 2048,
    }
  };

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });

  if (!res.ok) {
    const errData = await res.json().catch(() => ({}));
    const msg = errData?.error?.message || `HTTP ${res.status}`;
    throw new Error(msg);
  }

  const data = await res.json();
  return data?.candidates?.[0]?.content?.parts?.[0]?.text || '';
}

/* ── Parse & Render Results ── */
function renderResults(raw, { wantSummary, wantConcepts, wantQuiz }) {
  resultsEmpty.classList.add('hidden');
  resultsContent.classList.remove('hidden');
  resultsContent.innerHTML = '';

  const summaryText  = wantSummary  ? extractSection(raw, 'SUMMARY')       : null;
  const conceptsText = wantConcepts ? extractSection(raw, 'KEY_CONCEPTS')   : null;
  const quizText     = wantQuiz     ? extractSection(raw, 'QUIZ')           : null;

  if (summaryText) {
    resultsContent.appendChild(buildSummaryCard(summaryText));
  }
  if (conceptsText) {
    resultsContent.appendChild(buildConceptsCard(conceptsText));
  }
  if (quizText) {
    resultsContent.appendChild(buildQuizCard(quizText));
  }

  // Scroll to results on mobile
  if (window.innerWidth < 900) {
    resultsContent.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
}

/* ── Section Extractor ── */
function extractSection(text, label) {
  const regex = new RegExp(`${label}[:\\s\\n]+([\\s\\S]*?)(?=\\n\\d\\.\\s+[A-Z_]+:|$)`, 'i');
  const match = text.match(regex);
  return match ? match[1].trim() : text.trim(); // fallback to full text
}

/* ── Build Summary Card ── */
function buildSummaryCard(text) {
  const card = document.createElement('div');
  card.className = 'result-card';
  card.innerHTML = `
    <div class="card-header">
      <div class="card-dot dot-purple"></div>
      📄 Summary
    </div>
    <div class="card-body">${escapeHtml(text).replace(/\n/g, '<br/>')}</div>
    <div class="card-actions">
      <button class="btn-copy" data-copy="${encodeURIComponent(text)}">📋 Copy</button>
    </div>`;
  card.querySelector('.btn-copy').addEventListener('click', handleCopy);
  return card;
}

/* ── Build Key Concepts Card ── */
function buildConceptsCard(text) {
  const lines = text.split('\n').filter(l => l.trim());
  const items = lines.map(line => `<li>${escapeHtml(line.replace(/^[-•*]\s*/, ''))}</li>`).join('');

  const card = document.createElement('div');
  card.className = 'result-card';
  card.innerHTML = `
    <div class="card-header">
      <div class="card-dot dot-cyan"></div>
      💡 Key Concepts
    </div>
    <div class="card-body"><ul>${items}</ul></div>
    <div class="card-actions">
      <button class="btn-copy" data-copy="${encodeURIComponent(text)}">📋 Copy</button>
    </div>`;
  card.querySelector('.btn-copy').addEventListener('click', handleCopy);
  return card;
}

/* ── Build Quiz Card ── */
function buildQuizCard(text) {
  const card = document.createElement('div');
  card.className = 'result-card';

  const bodyEl = document.createElement('div');
  bodyEl.className = 'card-body';

  const questions = parseQuizQuestions(text);

  if (questions.length === 0) {
    // Fallback: just render as text
    bodyEl.innerHTML = text.replace(/\n/g, '<br/>');
  } else {
    questions.forEach((q, qi) => {
      const qEl = document.createElement('div');
      qEl.className = 'quiz-item';
      qEl.innerHTML = `<div class="quiz-q">Q${qi + 1}. ${escapeHtml(q.question)}</div>
        <div class="quiz-options">
          ${q.options.map((opt, oi) => `
            <div class="quiz-option" data-correct="${opt.correct}" data-qi="${qi}" data-oi="${oi}">
              ${escapeHtml(opt.text)}
            </div>`).join('')}
        </div>`;
      bodyEl.appendChild(qEl);
    });

    // Click handler for quiz options
    bodyEl.addEventListener('click', e => {
      const opt = e.target.closest('.quiz-option');
      if (!opt) return;
      const qi = opt.dataset.qi;
      // Find all options in this question
      const sibs = bodyEl.querySelectorAll(`.quiz-option[data-qi="${qi}"]`);
      sibs.forEach(s => {
        s.classList.remove('correct', 'wrong');
        if (s.dataset.correct === 'true') s.classList.add('correct');
        else if (s === opt) s.classList.add('wrong');
      });
    });
  }

  card.innerHTML = `
    <div class="card-header">
      <div class="card-dot dot-pink"></div>
      🧠 Quiz Questions
    </div>`;

  const actionsEl = document.createElement('div');
  actionsEl.className = 'card-actions';
  actionsEl.innerHTML = `<button class="btn-copy" data-copy="${encodeURIComponent(text)}">📋 Copy</button>
    <span style="font-size:0.75rem;color:var(--text-muted);margin-left:4px">Click an option to reveal answer</span>`;
  actionsEl.querySelector('.btn-copy').addEventListener('click', handleCopy);

  card.appendChild(bodyEl);
  card.appendChild(actionsEl);
  return card;
}

/* ── Parse Quiz Questions from raw text ── */
function parseQuizQuestions(text) {
  const questions = [];
  // Split by Q: or numbered patterns
  const qBlocks = text.split(/\n(?=Q:|Question\s*\d)/i).filter(b => b.trim());

  qBlocks.forEach(block => {
    const lines = block.split('\n').map(l => l.trim()).filter(Boolean);
    if (!lines.length) return;

    const qLine = lines[0].replace(/^Q[:\d.]*\s*/i, '').trim();
    const options = [];

    lines.slice(1).forEach(line => {
      const match = line.match(/^(\*?)([A-D][).:])\s*(.+)/i);
      if (match) {
        options.push({ text: `${match[2]} ${match[3]}`, correct: match[1] === '*' });
      }
    });

    if (qLine && options.length >= 2) {
      // If no option marked correct, mark first as fallback
      if (!options.some(o => o.correct)) options[0].correct = true;
      questions.push({ question: qLine, options });
    }
  });

  return questions;
}

/* ── Helpers ── */
function setLoading(on) {
  analyzeBtn.disabled = on;
  btnText.classList.toggle('hidden', on);
  btnLoader.classList.toggle('hidden', !on);
  if (!on) updateAnalyzeBtn();
}

function handleCopy(e) {
  const text = decodeURIComponent(e.currentTarget.dataset.copy);
  navigator.clipboard.writeText(text).then(() => showToast('✅ Copied to clipboard!'));
}

function escapeHtml(str) {
  return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function showToast(msg) {
  const old = document.querySelector('.toast');
  if (old) old.remove();
  const t = document.createElement('div');
  t.className = 'toast';
  t.textContent = msg;
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 3000);
}
