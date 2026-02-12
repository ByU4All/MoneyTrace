// MoneyTrace PWA - API Client
// v0.1.0 - Communicates with local FastAPI backend

const API = {
    baseUrl: '/api',  // API routes are under /api prefix

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

    // ---------------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------------

    /**
     * Create a new financial event
     */
    async createEvent(event) {
        return this.request('/events/', {
            method: 'POST',
            body: JSON.stringify(event)
        });
    },

    /**
     * Get all events
     */
    async getEvents() {
        return this.request('/events/');
    },

    // ---------------------------------------------------------------------------
    // Friends
    // ---------------------------------------------------------------------------

    /**
     * Create a new friend
     */
    async createFriend(friend) {
        return this.request('/friends/', {
            method: 'POST',
            body: JSON.stringify(friend)
        });
    },

    /**
     * Get all friends
     */
    async getFriends() {
        return this.request('/friends/');
    },

    /**
     * Get ledger for a specific friend
     */
    async getFriendLedger(friendId) {
        return this.request(`/friends/${friendId}/ledger`);
    },

    // ---------------------------------------------------------------------------
    // Views
    // ---------------------------------------------------------------------------

    /**
     * Get monthly summary
     */
    async getSummary(month, year) {
        return this.request(`/summary?month=${month}&year=${year}`);
    },

    /**
     * Get category spending for a month
     */
    async getCategories(month, year) {
        return this.request(`/categories?month=${month}&year=${year}`);
    }
};

// Export for use in other modules
window.API = API;

