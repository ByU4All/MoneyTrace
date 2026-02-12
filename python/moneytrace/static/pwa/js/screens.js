// MoneyTrace PWA - Screen Renderers
// v0.1.0 - Each screen is a pure function that returns HTML

const Screens = {

    /**
     * Convert minor units (paise) to major units (rupees)
     * @param {number} minorUnits - Amount in paise
     * @returns {number} - Amount in rupees
     */
    toMajorUnits(minorUnits) {
        return minorUnits / 100;
    },

    /**
     * Convert major units (rupees) to minor units (paise)
     * @param {number} majorUnits - Amount in rupees
     * @returns {number} - Amount in paise
     */
    toMinorUnits(majorUnits) {
        return Math.round(majorUnits * 100);
    },

    /**
     * Format amount from minor units to display string
     * @param {number} minorUnits - Amount in paise
     * @param {string} currency - Currency symbol (default: ₹)
     * @returns {string} - Formatted amount string
     */
    formatAmount(minorUnits, currency = '₹') {
        const major = this.toMajorUnits(minorUnits);
        return `${currency}${major.toLocaleString('en-IN', { minimumFractionDigits: 2 })}`;
    },

    // ---------------------------------------------------------------------------
    // Dashboard Screen
    // ---------------------------------------------------------------------------

    dashboard(data = null) {
        if (!data) {
            return `
                <div class="screen-dashboard">
                    <div class="loading">Loading dashboard...</div>
                </div>
            `;
        }

        return `
            <div class="screen-dashboard">
                <div class="card">
                    <div class="card-title">Budget Remaining</div>
                    <div class="card-value ${data.budget_remaining >= 0 ? 'positive' : 'negative'}">
                        ${this.formatAmount(data.budget_remaining)}
                    </div>
                </div>

                <div class="card">
                    <div class="card-title">Monthly Spend</div>
                    <div class="card-value">${this.formatAmount(data.monthly_spend)}</div>
                </div>

                <div class="card">
                    <div class="card-title">You Owe</div>
                    <div class="card-value negative">${this.formatAmount(data.outstanding_liabilities)}</div>
                </div>

                <div class="card">
                    <div class="card-title">You'll Receive</div>
                    <div class="card-value positive">${this.formatAmount(data.outstanding_receivables)}</div>
                </div>
            </div>
        `;
    },

    // ---------------------------------------------------------------------------
    // Add Event Screen
    // ---------------------------------------------------------------------------

    addEvent(friends = []) {
        const today = new Date().toISOString().split('T')[0];

        // Prepare friend options
        const friendOptions = friends.length > 0
            ? friends.map(f => `<option value="${f.id}">${f.name}</option>`).join('')
            : '<option value="">No friends available</option>';

        return `
            <div class="screen-add-event">
                <h2 class="mb-md">Add Event</h2>

                <form id="event-form">
                    <div class="form-group">
                        <label class="form-label">Type</label>
                        <select name="type" id="event-type" class="form-input" required>
                            <option value="expense">Expense</option>
                            <option value="liability_created">I Owe Someone</option>
                            <option value="receivable_created">Someone Owes Me</option>
                            <option value="payback_paid">I Paid Back</option>
                            <option value="payback_received">I Received Payment</option>
                            <option value="budget_adjustment">Budget Adjustment</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Amount (₹)</label>
                        <input type="number" name="amount" id="event-amount" class="form-input"
                               placeholder="0.00" step="0.01" min="0.01" required>
                        <small class="form-help" id="amount-display">Enter amount in rupees</small>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Category</label>
                        <input type="text" name="category" class="form-input"
                               placeholder="e.g., Eating Out, Transport" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Description</label>
                        <input type="text" name="description" class="form-input"
                               placeholder="What was this for?">
                    </div>

                    <div class="form-group" id="friend-group" style="display: none;">
                        <label class="form-label">Friend</label>
                        <select name="friend_id" id="friend-select" class="form-input">
                            <option value="">Select a friend</option>
                            ${friendOptions}
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Date</label>
                        <input type="date" name="event_date" class="form-input"
                               value="${today}" required>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width: 100%;">
                        Add Event
                    </button>
                </form>
            </div>
        `;
    },

    // ---------------------------------------------------------------------------
    // Friends Screen
    // ---------------------------------------------------------------------------

    friends(data = null) {
        if (!data) {
            return `
                <div class="screen-friends">
                    <div class="loading">Loading friends...</div>
                </div>
            `;
        }

        if (data.length === 0) {
            return `
                <div class="screen-friends">
                    <p class="text-center text-muted mt-md">No friends yet</p>
                </div>
            `;
        }

        const friendItems = data.map(friend => `
            <div class="list-item" data-friend-id="${friend.id}">
                <div class="list-item-content">
                    <div class="list-item-title">${friend.name}</div>
                    <div class="list-item-subtitle">${friend.phone || 'No phone'}</div>
                </div>
                <div class="list-item-value ${friend.balance >= 0 ? 'positive' : 'negative'}">
                    ${this.formatAmount(Math.abs(friend.balance))}
                    ${friend.balance >= 0 ? '↑' : '↓'}
                </div>
            </div>
        `).join('');

        return `
            <div class="screen-friends">
                <h2 class="mb-md">Friends</h2>
                ${friendItems}
            </div>
        `;
    },

    // ---------------------------------------------------------------------------
    // Categories Screen
    // ---------------------------------------------------------------------------

    categories(data = null) {
        if (!data) {
            return `
                <div class="screen-categories">
                    <div class="loading">Loading categories...</div>
                </div>
            `;
        }

        if (data.length === 0) {
            return `
                <div class="screen-categories">
                    <p class="text-center text-muted mt-md">No spending this month</p>
                </div>
            `;
        }

        const categoryItems = data.map(cat => `
            <div class="list-item">
                <div class="list-item-content">
                    <div class="list-item-title">${cat.category}</div>
                </div>
                <div class="list-item-value">${this.formatAmount(cat.amount)}</div>
            </div>
        `).join('');

        return `
            <div class="screen-categories">
                <h2 class="mb-md">Categories</h2>
                ${categoryItems}
            </div>
        `;
    }
};

// Export for use in other modules
window.Screens = Screens;

