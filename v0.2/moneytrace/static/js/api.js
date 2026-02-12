/**
 * MoneyTrace API Client
 *
 * Simple wrapper for communicating with the local Python backend.
 * All business logic stays in Python - this just fetches and sends data.
 */

const API = {
    baseUrl: '/api',

    /**
     * Make an API request
     */
    async request(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        const config = {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        };

        try {
            const response = await fetch(url, config);

            if (!response.ok) {
                const error = await response.json().catch(() => ({}));
                throw new Error(error.detail || `HTTP ${response.status}`);
            }

            return await response.json();
        } catch (err) {
            console.error(`API Error [${endpoint}]:`, err);
            throw err;
        }
    },

    // -------------------------------------------------------------------------
    // Summary
    // -------------------------------------------------------------------------

    async getSummary(month = null, year = null) {
        let endpoint = '/summary';
        if (month && year) {
            endpoint += `?month=${month}&year=${year}`;
        }
        return this.request(endpoint);
    },

    async getDashboard(month = null, year = null) {
        let endpoint = '/dashboard';
        if (month && year) {
            endpoint += `?month=${month}&year=${year}`;
        }
        return this.request(endpoint);
    },

    async getCategorySpending(month = null, year = null) {
        let endpoint = '/spending/categories';
        if (month && year) {
            endpoint += `?month=${month}&year=${year}`;
        }
        return this.request(endpoint);
    },

    async getCategoryList() {
        return this.request('/categories/list');
    },

    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    async createEvent(event) {
        return this.request('/events', {
            method: 'POST',
            body: JSON.stringify(event)
        });
    },

    async getEvents(limit = null) {
        let endpoint = '/events';
        if (limit) {
            endpoint += `?limit=${limit}`;
        }
        return this.request(endpoint);
    },

    // -------------------------------------------------------------------------
    // Friends
    // -------------------------------------------------------------------------

    async createFriend(friend) {
        return this.request('/friends', {
            method: 'POST',
            body: JSON.stringify(friend)
        });
    },

    async getFriends() {
        return this.request('/friends');
    },

    async getFriendDetails(friendId) {
        return this.request(`/friends/${friendId}`);
    },

    // -------------------------------------------------------------------------
    // Settings
    // -------------------------------------------------------------------------

    async getSettings() {
        return this.request('/settings');
    },

    async updateSettings(settings) {
        return this.request('/settings', {
            method: 'PUT',
            body: JSON.stringify(settings)
        });
    },

    async exportData() {
        return this.request('/export');
    },

    async clearData(keepFriends = true) {
        return this.request('/data/clear', {
            method: 'POST',
            body: JSON.stringify({
                confirm: 'DELETE',
                keep_friends: keepFriends
            })
        });
    },

    // -------------------------------------------------------------------------
    // Categories
    // -------------------------------------------------------------------------

    async getCategories() {
        return this.request('/categories');
    },

    async addCategory(name) {
        return this.request('/categories', {
            method: 'POST',
            body: JSON.stringify({ name })
        });
    },

    async updateCategory(categoryId, name) {
        return this.request(`/categories/${categoryId}`, {
            method: 'PUT',
            body: JSON.stringify({ name })
        });
    },

    async deleteCategory(categoryId, reassignTo = 'Other') {
        return this.request(`/categories/${categoryId}?reassign_to=${encodeURIComponent(reassignTo)}`, {
            method: 'DELETE'
        });
    }
};

// Export
window.API = API;

