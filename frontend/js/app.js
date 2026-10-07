// ============================================================================
// SkillLoop Main Frontend Application Controller
// ============================================================================

const state = {
  currentUser: null,
  currentView: 'dashboard',
  skills: [],
  categories: [],
  notifications: [],
};

// Toast notification helper
function showToast(message, type = 'success') {
  const container = document.getElementById('toast-container');
  if (!container) return;
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `<span>${type === 'success' ? '✓' : '⚠️'}</span> <span>${message}</span>`;
  container.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = '0';
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

// Router
async function navigate(viewName, params = {}) {
  state.currentView = viewName;
  document.querySelectorAll('.nav-item').forEach(el => {
    el.classList.toggle('active', el.dataset.view === viewName);
  });

  const contentArea = document.getElementById('view-content');
  contentArea.innerHTML = '<div style="text-align:center; padding: 60px;"><p style="color:var(--text-muted);">Loading view data...</p></div>';

  try {
    switch (viewName) {
      case 'dashboard':
        await renderDashboard(contentArea);
        break;
      case 'skills':
        await renderSkillsView(contentArea);
        break;
      case 'resources':
        await renderResourcesView(contentArea);
        break;
      case 'feed':
        await renderFeedView(contentArea);
        break;
      case 'exchange':
        await renderExchangeView(contentArea);
        break;
      case 'teams':
        await renderTeamsView(contentArea);
        break;
      case 'projects':
        await renderProjectsView(contentArea, params.projectId);
        break;
      case 'challenges':
        await renderChallengesView(contentArea);
        break;
      case 'analytics':
        await renderAnalyticsView(contentArea);
        break;
      case 'profile':
        await renderProfileView(contentArea);
        break;
      default:
        await renderDashboard(contentArea);
    }
  } catch (err) {
    console.error(err);
    contentArea.innerHTML = `<div class="card" style="border-color:var(--accent-rose);"><h3 style="color:var(--accent-rose);">Error Loading View</h3><p style="color:var(--text-muted);">${err.message}</p></div>`;
  }
}

// ============================================================================
// 1. DASHBOARD VIEW
// ============================================================================
async function renderDashboard(container) {
  const [analytics, goalsRes, sessionsRes, feedRes] = await Promise.all([
    window.api.getAnalyticsSummary(),
    window.api.getMyGoals().catch(() => ({ goals: [] })),
    window.api.getSessions().catch(() => ({ sessions: [] })),
    window.api.getPosts().catch(() => ({ posts: [] })),
  ]);

  const summary = analytics.summary;
  const user = state.currentUser;

  container.innerHTML = `
    <div style="margin-bottom: 28px;">
      <h1 style="font-size: 28px; font-weight: 800; letter-spacing: -0.5px;">Welcome back, ${user ? user.full_name : 'Student'}! 👋</h1>
      <p style="color: var(--text-muted); font-size: 15px;">Your student knowledge, mentorship exchange, and hackathon collaboration hub.</p>
    </div>

    <!-- Top KPI Metric Cards -->
    <div class="metrics-grid">
      <div class="metric-card">
        <span class="metric-label">Skill Credits Balance</span>
        <div class="metric-value" style="color: var(--accent-emerald);">${user ? Number(user.credit_balance || 5.0).toFixed(1) : '5.0'} 🪙</div>
        <span class="metric-subtext">Double-entry verified ledger</span>
      </div>
      <div class="metric-card purple">
        <span class="metric-label">Reputation Score</span>
        <div class="metric-value" style="color: #a78bfa;">${user ? user.reputation_score : '5.00'} ★</div>
        <span class="metric-subtext">Multi-dimensional rating</span>
      </div>
      <div class="metric-card emerald">
        <span class="metric-label">Completed Mentorships</span>
        <div class="metric-value">${summary.sessions_completed}</div>
        <span class="metric-subtext">Peer learning sessions settled</span>
      </div>
      <div class="metric-card amber">
        <span class="metric-label">Active Team Openings</span>
        <div class="metric-value">${summary.team_count}</div>
        <span class="metric-subtext">Hackathon & project vacancies</span>
      </div>
    </div>

    <!-- Active Goals & Quick Mentorship Match -->
    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px; margin-bottom: 28px;">
      <div class="card">
        <div class="section-header">
          <div>
            <h3 class="section-title">Active Learning Goals</h3>
            <p class="section-desc">Track roadmap milestones and prerequisite skills</p>
          </div>
          <button class="btn btn-primary btn-sm" onclick="openAddGoalModal()">+ Add Goal</button>
        </div>
        <div style="display: flex; flex-direction: column; gap: 14px;">
          ${(goalsRes.goals || []).map(g => `
            <div style="background: var(--bg-surface-elevated); padding: 16px; border-radius: var(--radius-md); border: 1px solid var(--border-subtle);">
              <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                <span style="font-weight: 600; font-size: 15px;">${g.title}</span>
                <span class="badge badge-cyan">${g.skill_name}</span>
              </div>
              <div style="background: rgba(255,255,255,0.06); height: 8px; border-radius: var(--radius-full); overflow: hidden; margin-bottom: 8px;">
                <div style="background: linear-gradient(90deg, var(--primary), var(--accent-purple)); width: ${g.progress_percent}%; height: 100%;"></div>
              </div>
              <div style="display: flex; justify-content: space-between; font-size: 12px; color: var(--text-subtle);">
                <span>Target: ${g.target_date || 'Ongoing'}</span>
                <span>${g.progress_percent}% Complete</span>
              </div>
            </div>
          `).join('') || '<p style="color:var(--text-subtle); padding: 16px 0;">No active learning goals yet. Click "+ Add Goal" above!</p>'}
        </div>
      </div>

      <!-- Quick Mentor Match Card -->
      <div class="card" style="background: linear-gradient(135deg, rgba(26, 34, 52, 0.9), rgba(139, 92, 246, 0.1));">
        <h3 class="section-title" style="font-size: 18px; margin-bottom: 6px;">Find a Peer Mentor</h3>
        <p class="section-desc" style="margin-bottom: 16px;">Deterministic matching based on verified skills & availability overlap.</p>
        <div class="form-group">
          <label class="form-label">What do you want to learn?</label>
          <select id="dash-mentor-skill" class="form-select">
            ${state.skills.map(s => `<option value="${s.id}">${s.name}</option>`).join('')}
          </select>
        </div>
        <button class="btn btn-purple" style="width: 100%;" onclick="runQuickMatch()">Run Matching Engine 🔍</button>
      </div>
    </div>

    <!-- Recent Sessions & Mutual Matches -->
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
      <!-- Upcoming Sessions -->
      <div class="card">
        <div class="section-header">
          <h3 class="section-title">My Learning Sessions</h3>
          <button class="btn btn-secondary btn-sm" onclick="navigate('exchange')">View All</button>
        </div>
        <div style="display: flex; flex-direction: column; gap: 12px;">
          ${(sessionsRes.sessions || []).slice(0, 3).map(s => `
            <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px; background: var(--bg-surface-elevated); border-radius: var(--radius-md); border: 1px solid var(--border-subtle);">
              <div>
                <div style="font-weight: 600; font-size: 14px;">${s.skill_name} Session</div>
                <div style="font-size: 12px; color: var(--text-muted);">With: ${s.teacher_name} • ${new Date(s.scheduled_start).toLocaleString()}</div>
              </div>
              <span class="badge ${s.status === 'COMPLETED' ? 'badge-emerald' : 'badge-cyan'}">${s.status}</span>
            </div>
          `).join('') || '<p style="color:var(--text-subtle);">No sessions scheduled yet.</p>'}
        </div>
      </div>

      <!-- Mutual Compatibility Insights (DBMS View: v_mutual_skill_matches) -->
      <div class="card">
        <div class="section-header">
          <div>
            <h3 class="section-title">Mutual Exchange Matches</h3>
            <p class="section-desc">Powered by view <code>v_mutual_skill_matches</code></p>
          </div>
        </div>
        <div style="display: flex; flex-direction: column; gap: 12px;">
          ${(analytics.mutual_matches || []).map(m => `
            <div style="padding: 12px; background: var(--bg-surface-elevated); border-radius: var(--radius-md); border: 1px solid var(--border-subtle); font-size: 13.5px;">
              <span style="color: var(--primary); font-weight: 600;">${m.user_a_name}</span> teaches <strong>${m.a_teaches_b}</strong> ⇆ 
              <span style="color: var(--accent-purple); font-weight: 600;">${m.user_b_name}</span> teaches <strong>${m.b_teaches_a}</strong>
            </div>
          `).join('') || '<p style="color:var(--text-subtle);">No mutual pair matches in current dataset.</p>'}
        </div>
      </div>
    </div>
  `;
}

// ============================================================================
// 2. SKILLS TAXONOMY & GRAPH VIEW
// ============================================================================
async function renderSkillsView(container) {
  const [categoriesRes, skillsRes, mySkillsRes] = await Promise.all([
    window.api.getCategories(),
    window.api.getSkills(),
    window.api.getMySkills().catch(() => ({ skills: [] })),
  ]);

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h1 style="font-size: 26px; font-weight: 800;">Skill Taxonomy & Graph Explorer</h1>
        <p class="section-desc">Master catalog with prerequisite relationships and student proficiencies</p>
      </div>
      <button class="btn btn-primary" onclick="openAddSkillModal()">+ Add to My Skills</button>
    </div>

    <!-- My Declared / Verified Skills -->
    <div class="card" style="margin-bottom: 28px;">
      <h3 class="section-title" style="margin-bottom: 16px;">My Verified Skills</h3>
      <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px;">
        ${(mySkillsRes.skills || []).map(s => `
          <div style="padding: 16px; background: var(--bg-surface-elevated); border-radius: var(--radius-md); border: 1px solid var(--border-subtle); display: flex; flex-direction: column; gap: 8px;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span style="font-weight: 700; font-size: 16px;">${s.skill_name}</span>
              <span class="badge badge-purple">${s.proficiency}</span>
            </div>
            <div style="font-size: 12.5px; color: var(--text-muted);">${s.category_name} • ${s.years_experience} yrs exp</div>
            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 4px;">
              <span class="badge ${s.verification_status !== 'UNVERIFIED' ? 'badge-emerald' : 'badge-amber'}">${s.verification_status}</span>
              <button class="btn btn-secondary btn-sm" onclick="deleteSkill(${s.skill_id})">Remove</button>
            </div>
          </div>
        `).join('') || '<p style="color:var(--text-subtle);">You haven\'t added skills to your profile yet.</p>'}
      </div>
    </div>

    <!-- Category Browser & Prerequisite Tree -->
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
      <div class="card">
        <h3 class="section-title" style="margin-bottom: 16px;">Master Skill Categories</h3>
        <div style="display: flex; flex-direction: column; gap: 12px;">
          ${(categoriesRes.categories || []).map(c => `
            <div style="padding: 14px; background: var(--bg-surface-elevated); border-radius: var(--radius-md); border: 1px solid var(--border-subtle);">
              <div style="font-weight: 700; font-size: 15px; color: var(--primary);">${c.name}</div>
              <div style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">${c.description}</div>
            </div>
          `).join('')}
        </div>
      </div>

      <div class="card">
        <h3 class="section-title" style="margin-bottom: 12px;">Interactive Prerequisite Inspector</h3>
        <p class="section-desc" style="margin-bottom: 16px;">Select any skill to inspect upstream prerequisite dependencies and downstream unlocks.</p>
        <div class="form-group">
          <select id="inspect-skill-select" class="form-select" onchange="inspectPrerequisites(this.value)">
            <option value="">-- Choose a skill to inspect --</option>
            ${(skillsRes.skills || []).map(s => `<option value="${s.id}">${s.name}</option>`).join('')}
          </select>
        </div>
        <div id="prereq-result-box" style="padding: 16px; background: var(--bg-main); border-radius: var(--radius-md); border: 1px dashed var(--border-subtle); min-height: 180px;">
          <p style="color: var(--text-subtle); text-align: center; margin-top: 50px;">Select a skill above to inspect its relational graph structure.</p>
        </div>
      </div>
    </div>
  `;
}

async function inspectPrerequisites(skillId) {
  if (!skillId) return;
  const box = document.getElementById('prereq-result-box');
  box.innerHTML = '<p style="color:var(--text-muted);">Traversing skill relationships in database...</p>';
  const res = await window.api.getSkillPrerequisites(skillId);
  const prereqs = res.prerequisites || [];
  const unlocks = res.unlocks || [];

  box.innerHTML = `
    <h4 style="color:#fff; font-size:16px; font-weight:700; margin-bottom:12px;">Skill: ${res.skill.name}</h4>
    <div style="margin-bottom: 14px;">
      <span style="font-size: 12px; font-weight: 700; color: var(--accent-amber); text-transform: uppercase;">Prerequisites Needed Before Learning:</span>
      <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 6px;">
        ${prereqs.map(p => `<span class="badge badge-amber">${p.name} (${p.relationship_type})</span>`).join('') || '<span style="color:var(--text-subtle); font-size:13px;">None (Entry level foundation skill)</span>'}
      </div>
    </div>
    <div>
      <span style="font-size: 12px; font-weight: 700; color: var(--accent-emerald); text-transform: uppercase;">Downstream Skills Unlocked:</span>
      <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 6px;">
        ${unlocks.map(u => `<span class="badge badge-emerald">${u.name}</span>`).join('') || '<span style="color:var(--text-subtle); font-size:13px;">None</span>'}
      </div>
    </div>
  `;
}

// ============================================================================
// 3. KNOWLEDGE HUB (RESOURCES & TUTORIALS)
// ============================================================================
async function renderResourcesView(container) {
  const [resourcesRes, skillsRes] = await Promise.all([
    window.api.getResources(),
    window.api.getSkills(),
  ]);

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h1 style="font-size: 26px; font-weight: 800;">Knowledge Hub & Tutorials</h1>
        <p class="section-desc">Handbooks, YouTube playlists, cheatsheets, and verified code repositories</p>
      </div>
      <button class="btn btn-primary" onclick="openAddResourceModal()">+ Publish Resource</button>
    </div>

    <!-- Filter Bar -->
    <div style="display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap;">
      <button class="btn btn-secondary btn-sm" onclick="filterResources('')">All Types</button>
      <button class="btn btn-secondary btn-sm" onclick="filterResources('NOTE')">Notes & Handbooks</button>
      <button class="btn btn-secondary btn-sm" onclick="filterResources('YOUTUBE_PLAYLIST')">YouTube Tutorials</button>
      <button class="btn btn-secondary btn-sm" onclick="filterResources('CODE_REPOSITORY')">Code Repos</button>
      <button class="btn btn-secondary btn-sm" onclick="filterResources('CHEAT_SHEET')">Cheat Sheets</button>
    </div>

    <!-- Resource Cards Grid -->
    <div id="resources-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 20px;">
      ${(resourcesRes.resources || []).map(r => `
        <div class="card" style="display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
              <span class="badge badge-cyan">${r.resource_type}</span>
              <span class="badge badge-purple">${r.skill_name}</span>
            </div>
            <h3 style="font-size: 17px; font-weight: 700; line-height: 1.3; margin-bottom: 8px;">${r.title}</h3>
            <p style="font-size: 13.5px; color: var(--text-muted); line-height: 1.4; margin-bottom: 14px;">${r.description || ''}</p>
          </div>
          <div>
            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: var(--text-subtle); padding-top: 12px; border-top: 1px solid var(--border-subtle); margin-bottom: 12px;">
              <span>By ${r.uploader_name}</span>
              <span>⭐ ${r.rating_avg} (${r.rating_count})</span>
            </div>
            <div style="display: flex; gap: 8px;">
              <a href="${r.content_url}" target="_blank" class="btn btn-primary btn-sm" style="flex: 1;">Open Resource ↗</a>
              <button class="btn btn-secondary btn-sm" onclick="openRateModal(${r.id})">Rate ⭐</button>
            </div>
          </div>
        </div>
      `).join('')}
    </div>
  `;
}

// ============================================================================
// 4. SOCIAL FEED & DISCUSSIONS
// ============================================================================
async function renderFeedView(container) {
  const postsRes = await window.api.getPosts();

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h1 style="font-size: 26px; font-weight: 800;">Student Discussion Feed</h1>
        <p class="section-desc">Knowledge exchanges, technical questions, project updates, and achievements</p>
      </div>
      <button class="btn btn-primary" onclick="openCreatePostModal()">+ Start Discussion</button>
    </div>

    <div style="display: flex; flex-direction: column; gap: 20px; max-width: 800px; margin: 0 auto;">
      ${(postsRes.posts || []).map(p => `
        <div class="card">
          <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 12px;">
            <img src="${p.author_avatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'}" class="avatar-sm" />
            <div>
              <div style="font-weight: 700; font-size: 14.5px;">${p.author_fullname} <span style="color:var(--text-subtle); font-weight:400;">@${p.author_name}</span></div>
              <div style="font-size: 12px; color: var(--text-subtle);">${new Date(p.created_at).toLocaleDateString()}</div>
            </div>
            <span class="badge badge-purple" style="margin-left: auto;">${p.post_type}</span>
          </div>
          <h3 style="font-size: 18px; font-weight: 700; margin-bottom: 8px;">${p.title}</h3>
          <p style="font-size: 14.5px; color: var(--text-muted); line-height: 1.5; margin-bottom: 16px; white-space: pre-line;">${p.content}</p>
          <div style="display: flex; gap: 16px; padding-top: 12px; border-top: 1px solid var(--border-subtle); font-size: 13px;">
            <button class="btn btn-secondary btn-sm" onclick="reactToPost(${p.id}, 'LIKE')">👍 ${p.reaction_count || 0} React</button>
            <button class="btn btn-secondary btn-sm" onclick="viewPostDetails(${p.id})">💬 ${p.comment_count || 0} Comments</button>
          </div>
        </div>
      `).join('')}
    </div>
  `;
}

// ============================================================================
// 5. SKILL EXCHANGE ENGINE & CREDITS
// ============================================================================
async function renderExchangeView(container) {
  const [offersRes, sessionsRes, creditRes] = await Promise.all([
    window.api.getOffers(),
    window.api.getSessions().catch(() => ({ sessions: [] })),
    window.api.getCreditHistory().catch(() => ({ account: { balance: 5.0 }, transactions: [] })),
  ]);

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h1 style="font-size: 26px; font-weight: 800;">Skill Exchange & Credit Ledger</h1>
        <p class="section-desc">Peer-to-peer learning with atomic double-entry Skill Credit settlement</p>
      </div>
      <button class="btn btn-purple" onclick="openOfferModal()">+ Offer to Teach</button>
    </div>

    <!-- Credit Wallet & Ledger Strip -->
    <div class="card" style="background: linear-gradient(135deg, rgba(14, 165, 233, 0.12), rgba(139, 92, 246, 0.12)); margin-bottom: 28px;">
      <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
          <span style="font-size: 13px; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">My Skill Credits Wallet</span>
          <div style="font-size: 32px; font-weight: 800; color: var(--accent-emerald);">${Number(creditRes.account.balance).toFixed(2)} Credits 🪙</div>
          <span style="font-size: 12px; color: var(--text-subtle);">Earned: ${creditRes.account.total_earned} | Spent: ${creditRes.account.total_spent}</span>
        </div>
        <button class="btn btn-secondary" onclick="openLedgerHistoryModal()">View Transaction Ledger 📜</button>
      </div>
    </div>

    <!-- Sessions Management -->
    <div class="card" style="margin-bottom: 28px;">
      <h3 class="section-title" style="margin-bottom: 16px;">My Learning & Teaching Sessions</h3>
      <div style="display: flex; flex-direction: column; gap: 12px;">
        ${(sessionsRes.sessions || []).map(s => `
          <div style="padding: 16px; background: var(--bg-surface-elevated); border-radius: var(--radius-md); border: 1px solid var(--border-subtle); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
            <div>
              <div style="font-weight: 700; font-size: 15px;">${s.skill_name} (${s.duration_minutes} min)</div>
              <div style="font-size: 13px; color: var(--text-muted);">Teacher: <strong>${s.teacher_name}</strong> | Learner: <strong>${s.learner_name}</strong></div>
              <div style="font-size: 12px; color: var(--text-subtle);">${new Date(s.scheduled_start).toLocaleString()}</div>
            </div>
            <div style="display: flex; align-items: center; gap: 10px;">
              <span class="badge ${s.status === 'COMPLETED' ? 'badge-emerald' : s.status === 'ACCEPTED' ? 'badge-purple' : 'badge-amber'}">${s.status}</span>
              ${s.status === 'REQUESTED' && s.teacher_id === state.currentUser?.id ? `
                <button class="btn btn-primary btn-sm" onclick="acceptSession(${s.id})">Accept Request</button>
              ` : ''}
              ${(s.status === 'ACCEPTED' || s.status === 'SCHEDULED') ? `
                <button class="btn btn-purple btn-sm" onclick="completeAndSettleSession(${s.id})">Complete & Settle Credits</button>
              ` : ''}
              ${s.status === 'COMPLETED' ? `
                <button class="btn btn-secondary btn-sm" onclick="openSessionReviewModal(${s.id})">Review ⭐</button>
              ` : ''}
            </div>
          </div>
        `).join('') || '<p style="color:var(--text-subtle);">No active sessions found.</p>'}
      </div>
    </div>

    <!-- Published Teaching Offers Grid -->
    <h3 class="section-title" style="margin-bottom: 16px;">Browse Available Mentors</h3>
    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px;">
      ${(offersRes.offers || []).map(o => `
        <div class="card" style="display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px;">
              <img src="${o.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'}" class="avatar-sm" />
              <div>
                <div style="font-weight: 700; font-size: 15px;">${o.full_name}</div>
                <div style="font-size: 12px; color: var(--text-subtle);">⭐ ${o.reputation_score} Rating</div>
              </div>
            </div>
            <span class="badge badge-cyan" style="margin-bottom: 8px;">Teaches: ${o.skill_name}</span>
            <p style="font-size: 13.5px; color: var(--text-muted); margin-bottom: 12px;">${o.description || 'Hands-on interactive learning session.'}</p>
          </div>
          <div>
            <div style="font-size: 12.5px; color: var(--text-subtle); margin-bottom: 12px;">
              ${o.session_duration_minutes} mins • ${o.session_format} • ${o.credit_cost} Credit
            </div>
            <button class="btn btn-primary btn-sm" style="width: 100%;" onclick="openRequestSessionModal(${o.user_id}, ${o.skill_id}, '${o.full_name}', '${o.skill_name}')">Request Session</button>
          </div>
        </div>
      `).join('')}
    </div>
  `;
}

// ============================================================================
// 6. HACKATHONS, TEAMS & OPPORTUNITIES
// ============================================================================
async function renderTeamsView(container) {
  const [competitionsRes, teamsRes, oppsRes] = await Promise.all([
    window.api.getCompetitions(),
    window.api.getTeams(),
    window.api.getOpportunities(),
  ]);

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h1 style="font-size: 26px; font-weight: 800;">Competitions & Hackathon Teams</h1>
        <p class="section-desc">Find teammates with complementary skills, recruit members, and win challenges</p>
      </div>
      <button class="btn btn-primary" onclick="openCreateTeamModal()">+ Create Team</button>
    </div>

    <!-- Active Competitions Strip -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 20px; margin-bottom: 32px;">
      ${(competitionsRes.competitions || []).map(c => `
        <div class="card" style="background: linear-gradient(135deg, rgba(26, 34, 52, 0.9), rgba(14, 165, 233, 0.08));">
          <span class="badge badge-purple" style="margin-bottom: 8px;">${c.competition_type}</span>
          <h3 style="font-size: 18px; font-weight: 700; margin-bottom: 6px;">${c.title}</h3>
          <p style="font-size: 13px; color: var(--text-muted); margin-bottom: 12px;">Organized by: ${c.organizer}</p>
          <div style="font-size: 12px; color: var(--accent-amber); margin-bottom: 12px;">⏳ Registration Deadline: ${new Date(c.registration_deadline).toLocaleDateString()}</div>
          <span class="badge badge-cyan">${c.team_count || 0} Registered Teams</span>
        </div>
      `).join('')}
    </div>

    <!-- Teams Recruiting Members -->
    <div class="section-header">
      <h3 class="section-title">Teams Looking for Members</h3>
    </div>
    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 20px;">
      ${(teamsRes.teams || []).map(t => `
        <div class="card">
          <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
            <h3 style="font-size: 18px; font-weight: 700;">${t.name}</h3>
            <span class="badge ${t.status === 'FULL' ? 'badge-amber' : 'badge-emerald'}">${t.current_member_count}/${t.max_members} Members</span>
          </div>
          <p style="font-size: 13.5px; color: var(--text-muted); margin-bottom: 14px;">${t.description || ''}</p>
          <div style="margin-bottom: 14px;">
            <span style="font-size: 12px; font-weight: 700; color: var(--text-subtle); text-transform: uppercase;">Open Roles:</span>
            <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 8px;">
              ${(t.openings || []).map(o => `
                <div style="padding: 8px 12px; background: var(--bg-surface-elevated); border-radius: var(--radius-sm); border: 1px solid var(--border-subtle); display: flex; justify-content: space-between; align-items: center;">
                  <div>
                    <span style="font-weight: 600; font-size: 13px;">${o.role_title}</span>
                    <div style="font-size: 11px; color: var(--primary);">Req: ${o.skill_name} (${o.min_proficiency})</div>
                  </div>
                  <button class="btn btn-primary btn-sm" onclick="openApplyTeamModal(${o.id}, '${t.name}', '${o.role_title}')">Apply</button>
                </div>
              `).join('') || '<p style="font-size: 12px; color: var(--text-subtle);">No open roles listed.</p>'}
            </div>
          </div>
          ${t.leader_id === state.currentUser?.id ? `
            <button class="btn btn-secondary btn-sm" style="width: 100%;" onclick="openPostOpeningModal(${t.id})">+ Add Role Vacancy</button>
          ` : ''}
        </div>
      `).join('')}
    </div>
  `;
}

// ============================================================================
// 7. PROJECTS & INTERACTIVE KANBAN BOARD
// ============================================================================
async function renderProjectsView(container, specificProjectId) {
  const projectsRes = await window.api.getProjects();
  const projects = projectsRes.projects || [];
  const selectedProjId = specificProjectId || (projects[0] ? projects[0].id : null);

  if (!selectedProjId) {
    container.innerHTML = `
      <div class="card" style="text-align: center; padding: 60px;">
        <h2>No Projects Found</h2>
        <button class="btn btn-primary" style="margin-top: 16px;" onclick="openCreateProjectModal()">+ Create Project</button>
      </div>
    `;
    return;
  }

  const projDetails = await window.api.getProject(selectedProjId);
  const p = projDetails.project;

  const tasks = p.tasks || [];
  const todoTasks = tasks.filter(t => t.status === 'TODO');
  const inProgressTasks = tasks.filter(t => t.status === 'IN_PROGRESS');
  const blockedTasks = tasks.filter(t => t.status === 'BLOCKED');
  const doneTasks = tasks.filter(t => t.status === 'DONE');

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h1 style="font-size: 26px; font-weight: 800;">${p.title}</h1>
        <p class="section-desc">${p.tagline || ''}</p>
      </div>
      <div style="display: flex; gap: 10px;">
        <button class="btn btn-secondary" onclick="openCreateProjectModal()">+ New Project</button>
        <button class="btn btn-primary" onclick="openAddTaskModal(${p.id})">+ Add Task</button>
      </div>
    </div>

    <!-- Project Tabs / Selector -->
    <div style="display: flex; gap: 8px; margin-bottom: 20px; overflow-x: auto; padding-bottom: 6px;">
      ${projects.map(proj => `
        <button class="btn ${proj.id === p.id ? 'btn-primary' : 'btn-secondary'} btn-sm" onclick="navigate('projects', { projectId: ${proj.id} })">
          ${proj.title}
        </button>
      `).join('')}
    </div>

    <!-- Project Problem/Solution Statement -->
    <div class="card" style="margin-bottom: 24px;">
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div>
          <h4 style="color: var(--accent-rose); font-size: 14px; font-weight: 700; text-transform: uppercase;">Problem Statement</h4>
          <p style="font-size: 13.5px; color: var(--text-muted); margin-top: 4px;">${p.problem_statement || 'N/A'}</p>
        </div>
        <div>
          <h4 style="color: var(--accent-emerald); font-size: 14px; font-weight: 700; text-transform: uppercase;">Relational Solution</h4>
          <p style="font-size: 13.5px; color: var(--text-muted); margin-top: 4px;">${p.solution_description || 'N/A'}</p>
        </div>
      </div>
    </div>

    <!-- Interactive 4-Column Kanban Board -->
    <h3 class="section-title">Project Kanban Board</h3>
    <div class="kanban-board">
      <!-- TODO Column -->
      <div class="kanban-col">
        <div class="kanban-col-header" style="color: var(--text-muted);">
          <span>TODO</span>
          <span class="badge badge-cyan">${todoTasks.length}</span>
        </div>
        ${todoTasks.map(t => renderTaskCard(t)).join('')}
      </div>

      <!-- IN_PROGRESS Column -->
      <div class="kanban-col">
        <div class="kanban-col-header" style="color: var(--primary);">
          <span>IN PROGRESS</span>
          <span class="badge badge-cyan">${inProgressTasks.length}</span>
        </div>
        ${inProgressTasks.map(t => renderTaskCard(t)).join('')}
      </div>

      <!-- BLOCKED Column -->
      <div class="kanban-col">
        <div class="kanban-col-header" style="color: var(--accent-rose);">
          <span>BLOCKED</span>
          <span class="badge badge-amber">${blockedTasks.length}</span>
        </div>
        ${blockedTasks.map(t => renderTaskCard(t)).join('')}
      </div>

      <!-- DONE Column -->
      <div class="kanban-col">
        <div class="kanban-col-header" style="color: var(--accent-emerald);">
          <span>DONE</span>
          <span class="badge badge-emerald">${doneTasks.length}</span>
        </div>
        ${doneTasks.map(t => renderTaskCard(t)).join('')}
      </div>
    </div>
  `;
}

function renderTaskCard(task) {
  return `
    <div class="task-card">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <span class="badge badge-purple">${task.priority}</span>
        <select onchange="updateTaskStatus(${task.id}, this.value)" style="background: transparent; border: 1px solid var(--border-subtle); color: var(--text-muted); font-size: 11px; border-radius: 4px; padding: 2px;">
          <option value="TODO" ${task.status === 'TODO' ? 'selected' : ''}>TODO</option>
          <option value="IN_PROGRESS" ${task.status === 'IN_PROGRESS' ? 'selected' : ''}>IN PROGRESS</option>
          <option value="BLOCKED" ${task.status === 'BLOCKED' ? 'selected' : ''}>BLOCKED</option>
          <option value="DONE" ${task.status === 'DONE' ? 'selected' : ''}>DONE</option>
        </select>
      </div>
      <div style="font-weight: 600; font-size: 14px;">${task.title}</div>
      <div style="font-size: 12px; color: var(--text-subtle);">${task.description || ''}</div>
      <div style="font-size: 11px; color: var(--primary); margin-top: 4px;">Assignee: ${task.assignee_name || 'Unassigned'}</div>
    </div>
  `;
}

async function updateTaskStatus(taskId, status) {
  await window.api.updateTaskStatus(taskId, status);
  showToast(`Task moved to ${status}`);
  navigate('projects');
}

// ============================================================================
// 8. CHALLENGES & XP
// ============================================================================
async function renderChallengesView(container) {
  const challengesRes = await window.api.getChallenges();

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h1 style="font-size: 26px; font-weight: 800;">Technical Challenges & XP</h1>
        <p class="section-desc">Prove competence through coding problems to earn verification status and XP</p>
      </div>
    </div>

    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 20px;">
      ${(challengesRes.challenges || []).map(c => `
        <div class="card" style="display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span class="badge badge-cyan">${c.skill_name}</span>
              <span class="badge badge-amber">${c.difficulty}</span>
            </div>
            <h3 style="font-size: 18px; font-weight: 700; margin-bottom: 6px;">${c.title}</h3>
            <p style="font-size: 13.5px; color: var(--text-muted); margin-bottom: 14px;">${c.description}</p>
          </div>
          <div>
            <div style="display: flex; justify-content: space-between; font-size: 12px; color: var(--text-subtle); margin-bottom: 12px; padding-top: 10px; border-top: 1px solid var(--border-subtle);">
              <span>Reward: <strong style="color:var(--accent-emerald);">+${c.xp_reward} XP</strong></span>
              <span>${c.completions || 0} Solved</span>
            </div>
            <button class="btn btn-primary btn-sm" style="width: 100%;" onclick="openSolveChallengeModal(${c.id}, '${c.title}', \`${escapeHtml(c.sample_code || '')}\`)">Solve Challenge ⚡</button>
          </div>
        </div>
      `).join('')}
    </div>
  `;
}

// ============================================================================
// 9. DBMS ANALYTICS & QUERY INSPECTOR VIEW
// ============================================================================
async function renderAnalyticsView(container) {
  const [analyticsRes, sqlRes] = await Promise.all([
    window.api.getAnalyticsSummary(),
    window.api.getDBMSQueries(),
  ]);

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h1 style="font-size: 26px; font-weight: 800;">DBMS Core & Query Explorer</h1>
        <p class="section-desc">Relational views, double-entry audit ledgers, and query demonstrations</p>
      </div>
    </div>

    <!-- Live Relational Views Showcase -->
    <div class="card" style="margin-bottom: 28px;">
      <h3 class="section-title" style="margin-bottom: 12px;">Relational View: <code>v_user_reputation</code></h3>
      <p class="section-desc" style="margin-bottom: 16px;">Multi-table aggregation computing student reputation across teaching ratings, completed projects, and XP.</p>
      <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse; font-size: 13.5px; text-align: left;">
          <thead>
            <tr style="border-bottom: 1px solid var(--border-subtle); color: var(--text-muted);">
              <th style="padding: 10px;">Username</th>
              <th style="padding: 10px;">Full Name</th>
              <th style="padding: 10px;">Reputation ★</th>
              <th style="padding: 10px;">Skill Credits</th>
              <th style="padding: 10px;">Sessions Taught</th>
              <th style="padding: 10px;">Avg Teaching Rating</th>
              <th style="padding: 10px;">Total XP</th>
            </tr>
          </thead>
          <tbody>
            ${(analyticsRes.top_reputation || []).map(r => `
              <tr style="border-bottom: 1px solid rgba(255,255,255,0.04);">
                <td style="padding: 10px; font-weight: 600; color: var(--primary);">@${r.username}</td>
                <td style="padding: 10px;">${r.full_name}</td>
                <td style="padding: 10px; color: var(--accent-amber); font-weight: 700;">${r.reputation_score}</td>
                <td style="padding: 10px; color: var(--accent-emerald); font-weight: 600;">${r.credit_balance} 🪙</td>
                <td style="padding: 10px;">${r.sessions_taught}</td>
                <td style="padding: 10px;">${Number(r.avg_teaching_rating).toFixed(2)}</td>
                <td style="padding: 10px; color: var(--accent-purple); font-weight: 700;">${r.total_xp} XP</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    </div>

    <!-- SQL Query Demonstrator -->
    <div class="card">
      <div class="section-header">
        <div>
          <h3 class="section-title">Demonstrated SQL Queries (20+ Scenarios)</h3>
          <p class="section-desc">Pre-tested queries modeling transactions, anti-gaps, and multi-criteria matching</p>
        </div>
      </div>
      <pre style="background: #080c14; border: 1px solid var(--border-subtle); border-radius: var(--radius-md); padding: 20px; font-family: 'JetBrains Mono', monospace; font-size: 12.5px; color: #38bdf8; overflow-x: auto; max-height: 480px;">${escapeHtml(sqlRes.sql_file)}</pre>
    </div>
  `;
}

// ============================================================================
// 10. PROFILE VIEW & DEMO USER SWITCHER
// ============================================================================
async function renderProfileView(container) {
  const user = state.currentUser;
  if (!user) return;

  container.innerHTML = `
    <div class="section-header">
      <div>
        <h1 style="font-size: 26px; font-weight: 800;">Student Profile & Settings</h1>
        <p class="section-desc">Academic details, verified skills, and fast demo identity switcher</p>
      </div>
    </div>

    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
      <!-- Profile Card -->
      <div class="card" style="text-align: center;">
        <img src="${user.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'}" style="width: 96px; height: 96px; border-radius: 50%; border: 3px solid var(--primary); margin-bottom: 12px;" />
        <h2 style="font-size: 20px; font-weight: 800;">${user.full_name}</h2>
        <p style="color: var(--text-muted); font-size: 14px; margin-bottom: 12px;">@${user.username} • Year ${user.year_of_study}</p>
        <div style="display: flex; gap: 6px; justify-content: center; margin-bottom: 16px;">
          ${(user.roles || []).map(r => `<span class="badge badge-purple">${r}</span>`).join('')}
        </div>
        <div style="padding: 12px; background: var(--bg-surface-elevated); border-radius: var(--radius-md); text-align: left; font-size: 13px; color: var(--text-muted);">
          <div>🏛️ <strong>${user.institution || 'NIT'}</strong></div>
          <div style="margin-top: 4px;">🎓 ${user.department || 'Computer Science'}</div>
        </div>
      </div>

      <!-- Quick Switcher Demo Accounts for Viva / Review -->
      <div class="card">
        <h3 class="section-title" style="margin-bottom: 12px;">Quick Persona Switcher (For Evaluation)</h3>
        <p class="section-desc" style="margin-bottom: 16px;">Switch between pre-seeded student personas to demonstrate role-based workflows.</p>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
          <button class="btn btn-secondary" onclick="quickLogin('sunesh')">👤 Sunesh (DB Lead & Admin)</button>
          <button class="btn btn-secondary" onclick="quickLogin('priya_dev')">👩‍💻 Priya (React & UI Lead)</button>
          <button class="btn btn-secondary" onclick="quickLogin('aravind_ai')">🤖 Aravind (ML Specialist)</button>
          <button class="btn btn-secondary" onclick="quickLogin('ananya_iot')">⚡ Ananya (ESP32 / IoT Lead)</button>
        </div>
      </div>
    </div>
  `;
}

// Helpers
function escapeHtml(str) {
  return (str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

async function quickLogin(username) {
  try {
    const res = await window.api.login(username, 'SkillLoopPass123!');
    state.currentUser = res.user;
    updateTopBarUser();
    showToast(`Logged in as @${username}`);
    navigate(state.currentView);
  } catch (err) {
    showToast(err.message, 'error');
  }
}

function updateTopBarUser() {
  const user = state.currentUser;
  if (!user) return;
  const nameEl = document.getElementById('user-quick-name');
  const creditEl = document.getElementById('user-quick-credits');
  const avatarEl = document.getElementById('user-quick-avatar');
  if (nameEl) nameEl.innerText = user.full_name;
  if (creditEl) creditEl.innerText = `${Number(user.credit_balance || 5.0).toFixed(1)} Credits 🪙`;
  if (avatarEl && user.avatar_url) avatarEl.src = user.avatar_url;
}

// Global modal triggers
window.openModal = function(id) {
  const modal = document.getElementById(id);
  if (modal) modal.classList.add('active');
};
window.closeModal = function(id) {
  const modal = document.getElementById(id);
  if (modal) modal.classList.remove('active');
};

// Modals logic
window.openAddGoalModal = () => openModal('modal-add-goal');
window.openAddSkillModal = () => openModal('modal-add-skill');
window.openAddResourceModal = () => openModal('modal-add-resource');
window.openCreatePostModal = () => openModal('modal-create-post');
window.openOfferModal = () => openModal('modal-publish-offer');
window.openCreateTeamModal = () => openModal('modal-create-team');
window.openCreateProjectModal = () => openModal('modal-create-project');

window.runQuickMatch = async function() {
  const skillSelect = document.getElementById('dash-mentor-skill');
  if (!skillSelect) return;
  const skillId = skillSelect.value;
  const res = await window.api.matchMentors(skillId);
  const matches = res.matches || [];
  if (matches.length === 0) {
    showToast('No mentors available for this skill yet.', 'error');
    return;
  }
  const top = matches[0];
  alert(`🎯 Top Mentor Match Found!\n\nMentor: ${top.full_name} (@${top.username})\nScore: ${top.match_score}/100\nReasons:\n• ${top.match_reasons.join('\n• ')}`);
};

window.acceptSession = async function(id) {
  await window.api.acceptSession(id);
  showToast('Session accepted!');
  navigate('exchange');
};

window.completeAndSettleSession = async function(id) {
  const res = await window.api.completeSession(id);
  showToast(res.message);
  // Refresh user balance
  const me = await window.api.getMe();
  state.currentUser = me.user;
  updateTopBarUser();
  navigate('exchange');
};

window.openRequestSessionModal = function(teacherId, skillId, teacherName, skillName) {
  document.getElementById('req-teacher-id').value = teacherId;
  document.getElementById('req-skill-id').value = skillId;
  document.getElementById('req-teacher-name').innerText = teacherName;
  document.getElementById('req-skill-name').innerText = skillName;
  openModal('modal-request-session');
};

window.openApplyTeamModal = function(openingId, teamName, roleTitle) {
  document.getElementById('apply-opening-id').value = openingId;
  document.getElementById('apply-team-name').innerText = teamName;
  document.getElementById('apply-role-title').innerText = roleTitle;
  openModal('modal-apply-team');
};

window.openSolveChallengeModal = function(id, title, sampleCode) {
  document.getElementById('solve-chal-id').value = id;
  document.getElementById('solve-chal-title').innerText = title;
  document.getElementById('solve-code-input').value = sampleCode || '// Write solution here\n';
  openModal('modal-solve-challenge');
};

// Initialization on load
window.addEventListener('DOMContentLoaded', async () => {
  try {
    // Attempt auto-login with demo user 1 (Sunesh) if token not present
    if (!window.api.token) {
      await quickLogin('sunesh');
    } else {
      const me = await window.api.getMe();
      state.currentUser = me.user;
      updateTopBarUser();
    }

    const [skillsRes, categoriesRes] = await Promise.all([
      window.api.getSkills(),
      window.api.getCategories(),
    ]);
    state.skills = skillsRes.skills || [];
    state.categories = categoriesRes.categories || [];

    // Populate global select dropdowns
    document.querySelectorAll('.populate-skills').forEach(el => {
      el.innerHTML = state.skills.map(s => `<option value="${s.id}">${s.name}</option>`).join('');
    });

    navigate('dashboard');
  } catch (err) {
    console.warn('Initial load fallback:', err);
    await quickLogin('sunesh');
  }
});
