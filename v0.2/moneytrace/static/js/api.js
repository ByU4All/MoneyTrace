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

    async getBudgetBreakdown(month = null, year = null) {
        let endpoint = '/budget/breakdown';
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

    async deleteEvent(eventId) {
        return this.request(`/events/${eventId}`, {
            method: 'DELETE'
        });
    },

    async getTimeline(limit = 100, detailed = false) {
        return this.request(`/events/timeline?limit=${limit}&detailed=${detailed}`);
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

    async updateFriend(friendId, data) {
        return this.request(`/friends/${friendId}`, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    },

    async deleteFriend(friendId) {
        return this.request(`/friends/${friendId}`, {
            method: 'DELETE'
        });
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

    async importData(file) {
        const formData = new FormData();
        formData.append('file', file);

        try {
            const response = await fetch(`${this.baseUrl}/import`, {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                const error = await response.json().catch(() => ({}));
                throw new Error(error.detail || `HTTP ${response.status}`);
            }

            return await response.json();
        } catch (err) {
            console.error('API Error [/import]:', err);
            throw err;
        }
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
    },

    // -------------------------------------------------------------------------
    // Accounts
    // -------------------------------------------------------------------------

    async getAccounts() {
        return this.request('/accounts');
    },

    async createAccount(account) {
        return this.request('/accounts', {
            method: 'POST',
            body: JSON.stringify(account)
        });
    },

    async getAccount(accountId) {
        return this.request(`/accounts/${accountId}`);
    },

    async updateAccount(accountId, updates) {
        return this.request(`/accounts/${accountId}`, {
            method: 'PUT',
            body: JSON.stringify(updates)
        });
    },

    async deleteAccount(accountId) {
        return this.request(`/accounts/${accountId}`, {
            method: 'DELETE'
        });
    },

    async getAccountEvents(accountId, limit = 50) {
        return this.request(`/accounts/${accountId}/events?limit=${limit}`);
    },

    async createTransfer(fromAccountId, toAccountId, amount, description = null) {
        return this.request('/accounts/transfer', {
            method: 'POST',
            body: JSON.stringify({
                from_account_id: fromAccountId,
                to_account_id: toAccountId,
                amount,
                description
            })
        });
    },

    // -------------------------------------------------------------------------
    // Recurring Transactions
    // -------------------------------------------------------------------------

    async getRecurring() {
        return this.request('/recurring');
    },

    async getRecurringById(recurringId) {
        return this.request(`/recurring/${recurringId}`);
    },

    async createRecurring(recurring) {
        return this.request('/recurring', {
            method: 'POST',
            body: JSON.stringify(recurring)
        });
    },

    async updateRecurring(recurringId, updates) {
        return this.request(`/recurring/${recurringId}`, {
            method: 'PUT',
            body: JSON.stringify(updates)
        });
    },

    async deleteRecurring(recurringId) {
        return this.request(`/recurring/${recurringId}`, {
            method: 'DELETE'
        });
    },

    async getPendingTransactions() {
        return this.request('/recurring/pending');
    },

    async confirmPending(pendingId) {
        return this.request(`/recurring/pending/${pendingId}/confirm`, {
            method: 'POST'
        });
    },

    async skipPending(pendingId) {
        return this.request(`/recurring/pending/${pendingId}/skip`, {
            method: 'POST'
        });
    },

    async getUpcomingBills(days = 30) {
        return this.request(`/recurring/upcoming?days=${days}`);
    },

    async payRecurringEarly(recurringId, accountId = null) {
        let endpoint = `/recurring/${recurringId}/pay-early`;
        if (accountId) {
            endpoint += `?account_id=${accountId}`;
        }
        return this.request(endpoint, {
            method: 'POST'
        });
    },

    async checkDueRecurring() {
        return this.request('/recurring/due');
    },

    // -------------------------------------------------------------------------
    // Loans
    // -------------------------------------------------------------------------

    async getLoans() {
        return this.request('/loans');
    },

    async createLoan(loan) {
        return this.request('/loans', {
            method: 'POST',
            body: JSON.stringify(loan)
        });
    },

    async getLoan(loanId) {
        return this.request(`/loans/${loanId}`);
    },

    async updateLoan(loanId, updates) {
        return this.request(`/loans/${loanId}`, {
            method: 'PUT',
            body: JSON.stringify(updates)
        });
    },

    async closeLoan(loanId) {
        return this.request(`/loans/${loanId}`, {
            method: 'DELETE'
        });
    },

    async payEmi(loanId, amount = null, accountId = null) {
        let url = `/loans/${loanId}/pay`;
        const params = [];
        if (amount) params.push(`amount=${amount}`);
        if (accountId) params.push(`account_id=${accountId}`);
        if (params.length) url += '?' + params.join('&');

        return this.request(url, { method: 'POST' });
    },

    async getLoanSchedule(loanId) {
        return this.request(`/loans/${loanId}/schedule`);
    },

    async getLoanEmiSchedule(loanId) {
        return this.request(`/loans/${loanId}/emi-schedule`);
    },

    async setLoanEmiSchedule(loanId, schedule) {
        return this.request(`/loans/${loanId}/emi-schedule`, {
            method: 'PUT',
            body: JSON.stringify({ schedule })
        });
    },

    async deleteLoanEmiSchedule(loanId) {
        return this.request(`/loans/${loanId}/emi-schedule`, {
            method: 'DELETE'
        });
    },

    // -------------------------------------------------------------------------
    // Credit Cards
    // -------------------------------------------------------------------------

    async getCreditCards() {
        return this.request('/credit-cards');
    },

    async getCreditCardDetails(cardId) {
        return this.request(`/credit-cards/${cardId}`);
    },

    async getCardStatements(cardId, unpaidOnly = false) {
        return this.request(`/credit-cards/${cardId}/statements?unpaid_only=${unpaidOnly}`);
    },

    async createCardStatement(cardId, statement) {
        return this.request(`/credit-cards/${cardId}/statements`, {
            method: 'POST',
            body: JSON.stringify({
                ...statement,
                card_account_id: cardId
            })
        });
    },

    async payCreditCard(statementId, amount, fromAccountId) {
        return this.request('/credit-cards/pay', {
            method: 'POST',
            body: JSON.stringify({
                statement_id: statementId,
                amount,
                from_account_id: fromAccountId
            })
        });
    }
};

// Export
window.API = API;

