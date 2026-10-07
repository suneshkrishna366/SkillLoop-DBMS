// ============================================================================
// SkillLoop Frontend API Client
// Handles authentication tokens, request dispatch, and error parsing
// ============================================================================

const API_BASE = window.location.origin;

class APIClient {
  constructor() {
    this.token = localStorage.getItem('skillloop_token') || '';
  }

  setToken(token) {
    this.token = token;
    if (token) {
      localStorage.setItem('skillloop_token', token);
    } else {
      localStorage.removeItem('skillloop_token');
    }
  }

  async request(endpoint, options = {}) {
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    try {
      const response = await fetch(`${API_BASE}${endpoint}`, {
        ...options,
        headers,
      });

      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        const errorMsg = data?.error?.message || `HTTP ${response.status} Error`;
        throw new Error(errorMsg);
      }

      return data;
    } catch (err) {
      console.error(`API Error on ${endpoint}:`, err);
      throw err;
    }
  }

  // Auth
  async login(username_or_email, password) {
    const res = await this.request('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ username_or_email, password }),
    });
    this.setToken(res.token);
    return res;
  }

  async register(data) {
    const res = await this.request('/api/auth/register', {
      method: 'POST',
      body: JSON.stringify(data),
    });
    this.setToken(res.token);
    return res;
  }

  async getMe() {
    return this.request('/api/auth/me');
  }

  async logout() {
    await this.request('/api/auth/logout', { method: 'POST' });
    this.setToken('');
  }

  // Skills
  async getCategories() { return this.request('/api/skills/categories'); }
  async getSkills() { return this.request('/api/skills'); }
  async getSkillPrerequisites(skillId) { return this.request(`/api/skills/${skillId}/prerequisites`); }
  async getMySkills() { return this.request('/api/users/me/skills'); }
  async addMySkill(data) { return this.request('/api/users/me/skills', { method: 'POST', body: JSON.stringify(data) }); }
  async deleteMySkill(skillId) { return this.request(`/api/users/me/skills/${skillId}`, { method: 'DELETE' }); }
  async getMyGoals() { return this.request('/api/users/me/goals'); }
  async addMyGoal(data) { return this.request('/api/users/me/goals', { method: 'POST', body: JSON.stringify(data) }); }

  // Knowledge Hub
  async getResources(params = {}) {
    const qs = new URLSearchParams(params).toString();
    return this.request(`/api/resources${qs ? '?' + qs : ''}`);
  }
  async publishResource(data) {
    return this.request('/api/resources', { method: 'POST', body: JSON.stringify(data) });
  }
  async rateResource(id, rating, review_text) {
    return this.request(`/api/resources/${id}/ratings`, { method: 'POST', body: JSON.stringify({ rating, review_text }) });
  }

  // Social Feed
  async getPosts(type = '') {
    return this.request(`/api/posts${type ? '?type=' + type : ''}`);
  }
  async getPost(id) { return this.request(`/api/posts/${id}`); }
  async createPost(data) { return this.request('/api/posts', { method: 'POST', body: JSON.stringify(data) }); }
  async addComment(postId, content) {
    return this.request(`/api/posts/${postId}/comments`, { method: 'POST', body: JSON.stringify({ content }) });
  }
  async reactPost(postId, reaction_type) {
    return this.request(`/api/posts/${postId}/reactions`, { method: 'POST', body: JSON.stringify({ reaction_type }) });
  }

  // Skill Exchange & Credits
  async getOffers() { return this.request('/api/exchange/offers'); }
  async matchMentors(skill_id) {
    return this.request('/api/exchange/match', { method: 'POST', body: JSON.stringify({ skill_id }) });
  }
  async publishOffer(data) { return this.request('/api/exchange/offers', { method: 'POST', body: JSON.stringify(data) }); }
  async getSessions() { return this.request('/api/exchange/sessions'); }
  async requestSession(data) { return this.request('/api/exchange/sessions', { method: 'POST', body: JSON.stringify(data) }); }
  async acceptSession(id, meeting_url) { return this.request(`/api/exchange/sessions/${id}/accept`, { method: 'POST', body: JSON.stringify({ meeting_url }) }); }
  async completeSession(id) { return this.request(`/api/exchange/sessions/${id}/complete`, { method: 'POST' }); }
  async reviewSession(id, data) { return this.request(`/api/exchange/sessions/${id}/review`, { method: 'POST', body: JSON.stringify(data) }); }
  async getCreditHistory() { return this.request('/api/exchange/credits'); }

  // Competitions, Teams & Opportunities
  async getCompetitions() { return this.request('/api/competitions'); }
  async getTeams() { return this.request('/api/teams'); }
  async createTeam(data) { return this.request('/api/teams', { method: 'POST', body: JSON.stringify(data) }); }
  async postTeamOpening(teamId, data) { return this.request(`/api/teams/${teamId}/openings`, { method: 'POST', body: JSON.stringify(data) }); }
  async applyTeamOpening(openingId, pitch_message) { return this.request(`/api/teams/openings/${openingId}/apply`, { method: 'POST', body: JSON.stringify({ pitch_message }) }); }
  async reviewTeamApp(appId, action) { return this.request(`/api/teams/applications/${appId}/review`, { method: 'POST', body: JSON.stringify({ action }) }); }
  async getOpportunities() { return this.request('/api/opportunities'); }

  // Projects & Challenges
  async getProjects() { return this.request('/api/projects'); }
  async getProject(id) { return this.request(`/api/projects/${id}`); }
  async createProject(data) { return this.request('/api/projects', { method: 'POST', body: JSON.stringify(data) }); }
  async createProjectTask(projId, data) { return this.request(`/api/projects/${projId}/tasks`, { method: 'POST', body: JSON.stringify(data) }); }
  async updateTaskStatus(taskId, status) { return this.request(`/api/projects/tasks/${taskId}`, { method: 'PATCH', body: JSON.stringify({ status }) }); }
  async getChallenges() { return this.request('/api/challenges'); }
  async submitChallenge(id, code_submission) { return this.request(`/api/challenges/${id}/submit`, { method: 'POST', body: JSON.stringify({ code_submission }) }); }

  // Analytics & Notifications
  async getAnalyticsSummary() { return this.request('/api/analytics/summary'); }
  async getDBMSQueries() { return this.request('/api/analytics/queries'); }
  async getNotifications() { return this.request('/api/notifications'); }
}

window.api = new APIClient();
