/**
 * MoneyTrace Screen Renderers
 *
 * Each screen is a pure function that returns HTML.
 * No business logic here - just presentation.
 */

const Screens = {

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    /**
     * Format amount from paise to rupees display
     */
    formatAmount(paise, showSign = false) {
        const rupees = paise / 100;
        const formatted = '₹' + Math.abs(rupees).toLocaleString('en-IN', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        });

        if (showSign && paise !== 0) {
            return paise > 0 ? '+' + formatted : '-' + formatted;
        }
        return formatted;
    },

    /**
     * Get icon for event type
     */
    getEventIcon(type) {
        const icons = {
            expense: '💸',
            liability: '📤',
            receivable: '📥',
            settlement_paid: '💳',
            settlement_received: '💰',
            budget_adjustment: '📊'
        };
        return icons[type] || '📝';
    },

    /**
     * Get friendly name for event type
     */
    getEventTypeName(type) {
        const names = {
            expense: 'Expense',
            liability: 'I Owe',
            receivable: 'Owes Me',
            settlement_paid: 'Paid Back',
            settlement_received: 'Received',
            budget_adjustment: 'Adjustment'
        };
        return names[type] || type;
    },

    // -------------------------------------------------------------------------
    // Dashboard Screen
    // -------------------------------------------------------------------------

    dashboard(data = null) {
        if (!data) {
            return '<div class="loading">Loading...</div>';
        }

        const budgetClass = data.budget_remaining >= 0 ? 'positive' : 'negative';

        // Build friends who owe me section
        let friendsOweMeHtml = '';
        if (data.friends_owe_me && data.friends_owe_me.length > 0) {
            const friendItems = data.friends_owe_me.map(f => `
                <div class="friend-balance-item" data-friend-id="${f.id}">
                    <span class="friend-name">${f.name}</span>
                    <span class="friend-amount positive">+${this.formatAmount(f.amount)}</span>
                </div>
            `).join('');
            friendsOweMeHtml = `
                <div class="dashboard-section">
                    <div class="section-header-small">
                        <span class="section-icon">📥</span>
                        <span>Owed to Me</span>
                    </div>
                    <div class="friend-balance-list">
                        ${friendItems}
                    </div>
                </div>
            `;
        }

        // Build friends I owe section
        let friendsIOweHtml = '';
        if (data.friends_i_owe && data.friends_i_owe.length > 0) {
            const friendItems = data.friends_i_owe.map(f => `
                <div class="friend-balance-item" data-friend-id="${f.id}">
                    <span class="friend-name">${f.name}</span>
                    <span class="friend-amount negative">-${this.formatAmount(f.amount)}</span>
                </div>
            `).join('');
            friendsIOweHtml = `
                <div class="dashboard-section">
                    <div class="section-header-small">
                        <span class="section-icon">📤</span>
                        <span>I Owe</span>
                    </div>
                    <div class="friend-balance-list">
                        ${friendItems}
                    </div>
                </div>
            `;
        }

        // Build category spending section
        let categoriesHtml = '';
        if (data.categories && data.categories.length > 0) {
            const categoryItems = data.categories.map(c => `
                <div class="category-spend-item">
                    <div class="category-info">
                        <span class="category-name">${c.category}</span>
                        <span class="category-amount">${this.formatAmount(c.amount)}</span>
                    </div>
                    <div class="category-bar-container">
                        <div class="category-bar" style="width: ${c.percentage}%"></div>
                    </div>
                    <span class="category-percentage">${c.percentage}%</span>
                </div>
            `).join('');
            categoriesHtml = `
                <div class="dashboard-section">
                    <div class="section-header-small">
                        <span class="section-icon">📊</span>
                        <span>Spending by Category</span>
                    </div>
                    <div class="category-spend-list">
                        ${categoryItems}
                    </div>
                </div>
            `;
        }

        // Build upcoming bills section
        let upcomingBillsHtml = '';
        if (data.upcoming_bills && data.upcoming_bills.length > 0) {
            const unpaidBills = data.upcoming_bills.filter(b => !b.is_paid);
            if (unpaidBills.length > 0) {
                const billItems = unpaidBills.map(b => {
                    let statusClass = 'upcoming';
                    let statusIcon = '📅';
                    if (b.is_overdue) {
                        statusClass = 'overdue';
                        statusIcon = '🔴';
                    } else if (b.days_until_due <= 3) {
                        statusClass = 'due-soon';
                        statusIcon = '🟡';
                    }
                    const autopayBadge = b.is_autopay ? '<span class="autopay-badge">Auto</span>' : '';

                    return `
                        <div class="upcoming-bill-item ${statusClass}" data-recurring-id="${b.id}">
                            <div class="bill-icon">${statusIcon}</div>
                            <div class="bill-info">
                                <div class="bill-name">${b.name} ${autopayBadge}</div>
                                <div class="bill-due">${b.is_overdue ? 'Overdue' : `Due ${b.due_date}`}</div>
                            </div>
                            <div class="bill-amount">${this.formatAmount(b.amount)}</div>
                        </div>
                    `;
                }).join('');

                upcomingBillsHtml = `
                    <div class="dashboard-section upcoming-bills-section">
                        <div class="section-header-small">
                            <span class="section-icon">📋</span>
                            <span>Upcoming Bills</span>
                            ${data.unpaid_recurring ? `<span class="reserved-amount">Reserved: ${this.formatAmount(data.unpaid_recurring)}</span>` : ''}
                        </div>
                        <div class="upcoming-bills-list">
                            ${billItems}
                        </div>
                    </div>
                `;
            }
        }

        return `
            <div class="screen-dashboard">
                <!-- Main Budget Display -->
                <div class="card budget-card">
                    <div class="dashboard-budget">
                        <div class="dashboard-budget-label">Budget Remaining</div>
                        <div class="dashboard-budget-value ${budgetClass}">
                            ${this.formatAmount(data.budget_remaining)}
                        </div>
                        <div class="dashboard-budget-base">
                            of ${this.formatAmount(data.base_budget)} monthly
                            ${data.unpaid_recurring ? `<br><span class="budget-reserved">incl. ${this.formatAmount(data.unpaid_recurring)} reserved for bills</span>` : ''}
                        </div>
                    </div>
                </div>

                <!-- Upcoming Bills -->
                ${upcomingBillsHtml}

                <!-- Summary Grid -->
                <div class="summary-grid">
                    <div class="summary-card">
                        <div class="summary-card-title">Spent</div>
                        <div class="summary-card-value">
                            ${this.formatAmount(data.monthly_spend)}
                        </div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-card-title">I Owe</div>
                        <div class="summary-card-value negative">
                            ${this.formatAmount(data.outstanding_liabilities)}
                        </div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-card-title">Owed to Me</div>
                        <div class="summary-card-value positive">
                            ${this.formatAmount(data.outstanding_receivables)}
                        </div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-card-title">Month</div>
                        <div class="summary-card-value">
                            ${this.getMonthName(data.month)}
                        </div>
                    </div>
                </div>

                <!-- Friends Owed to Me -->
                ${friendsOweMeHtml}

                <!-- Friends I Owe -->
                ${friendsIOweHtml}

                <!-- Category Spending -->
                ${categoriesHtml}
            </div>
        `;
    },

    getMonthName(month) {
        const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[month] || '';
    },

    // -------------------------------------------------------------------------
    // Add Event Screen
    // -------------------------------------------------------------------------

    addEvent(categories = [], friends = [], accounts = []) {
        const today = new Date().toISOString().split('T')[0];

        const categoryOptions = categories
            .map(c => `<option value="${c.name}">${c.name}</option>`)
            .join('');

        const friendOptions = friends
            .map(f => `<option value="${f.id}">${f.name}</option>`)
            .join('');

        const accountOptions = accounts
            .map(a => `<option value="${a.id}">${this._getAccountIcon(a.type)} ${a.name}</option>`)
            .join('');

        return `
            <div class="screen-add">
                <!-- Event Type Selector - Row 1: Main Types -->
                <div class="type-selector">
                    <button class="type-btn active" data-type="expense">
                        <span class="type-btn-icon">💸</span>
                        Expense
                    </button>
                    <button class="type-btn" data-type="income">
                        <span class="type-btn-icon">💰</span>
                        Income
                    </button>
                    <button class="type-btn" data-type="transfer">
                        <span class="type-btn-icon">🔄</span>
                        Transfer
                    </button>
                </div>

                <!-- Event Type Selector - Row 2: Friend Related -->
                <div class="type-selector type-selector-secondary">
                    <button class="type-btn" data-type="liability">
                        <span class="type-btn-icon">📤</span>
                        I Owe
                    </button>
                    <button class="type-btn" data-type="receivable">
                        <span class="type-btn-icon">📥</span>
                        Owes Me
                    </button>
                    <button class="type-btn" data-type="settlement">
                        <span class="type-btn-icon">🤝</span>
                        Settle
                    </button>
                </div>

                <form id="event-form">
                    <input type="hidden" name="type" value="expense">

                    <!-- Amount -->
                    <div class="form-group">
                        <label class="form-label">Amount (₹)</label>
                        <input type="number" 
                               name="amount" 
                               class="form-input form-input-amount" 
                               placeholder="0"
                               step="1" 
                               min="1" 
                               inputmode="numeric"
                               required>
                    </div>

                    <!-- Account Selection (single account) -->
                    <div class="form-group" id="account-group">
                        <label class="form-label" id="account-label">Paid From</label>
                        <select name="account_id" class="form-input">
                            <option value="">-- Select Account --</option>
                            ${accountOptions}
                        </select>
                        <span class="form-help" id="account-help">Which account was used?</span>
                    </div>

                    <!-- Transfer Accounts (hidden by default) -->
                    <div class="form-group hidden" id="transfer-group">
                        <label class="form-label">Transfer Details</label>
                        <div class="form-row">
                            <div class="form-col">
                                <label class="form-label-small">From</label>
                                <select name="from_account_id" class="form-input">
                                    <option value="">-- Select --</option>
                                    ${accountOptions}
                                </select>
                            </div>
                            <div class="form-col">
                                <label class="form-label-small">To</label>
                                <select name="to_account_id" class="form-input">
                                    <option value="">-- Select --</option>
                                    ${accountOptions}
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Category -->
                    <div class="form-group" id="category-group">
                        <label class="form-label">Category</label>
                        <select name="category" class="form-input" required>
                            <option value="">Select category</option>
                            ${categoryOptions}
                        </select>
                    </div>

                    <!-- Friend (hidden by default) -->
                    <div class="form-group hidden" id="friend-group">
                        <label class="form-label" id="friend-label">Friend</label>
                        <select name="friend_id" class="form-input">
                            <option value="">Select friend</option>
                            ${friendOptions}
                        </select>
                    </div>

                    <!-- Settlement Direction (hidden by default) -->
                    <div class="form-group hidden" id="settlement-direction-group">
                        <label class="form-label">Settlement Type</label>
                        <div class="settlement-toggle">
                            <button type="button" class="settlement-btn active" data-direction="paid">
                                💳 I'm Paying
                            </button>
                            <button type="button" class="settlement-btn" data-direction="received">
                                💰 I'm Receiving
                            </button>
                        </div>
                    </div>

                    <!-- Description -->
                    <div class="form-group">
                        <label class="form-label">Description (optional)</label>
                        <input type="text" 
                               name="description" 
                               class="form-input" 
                               placeholder="What was this for?">
                    </div>

                    <!-- Date -->
                    <div class="form-group">
                        <label class="form-label">Date</label>
                        <input type="date" 
                               name="event_date" 
                               class="form-input" 
                               value="${today}">
                    </div>

                    <!-- Submit -->
                    <button type="submit" class="btn btn-primary btn-block btn-lg">
                        Add Event
                    </button>
                </form>
            </div>
        `;
    },

    // -------------------------------------------------------------------------
    // Friends Screen
    // -------------------------------------------------------------------------

    friends(data = null, showAddForm = false) {
        if (!data) {
            return '<div class="loading">Loading...</div>';
        }

        // Add friend form
        const addForm = showAddForm ? `
            <div class="card mb-md">
                <form id="add-friend-form">
                    <div class="form-group">
                        <label class="form-label">Friend's Name</label>
                        <input type="text" 
                               name="name" 
                               class="form-input" 
                               placeholder="Enter name"
                               required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Phone (optional)</label>
                        <input type="tel" 
                               name="phone" 
                               class="form-input" 
                               placeholder="Phone number">
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">
                        Add Friend
                    </button>
                </form>
            </div>
        ` : '';

        // Friend list
        let friendsList = '';
        if (data.length === 0) {
            friendsList = `
                <div class="empty-state">
                    <div class="empty-state-icon">👥</div>
                    <div class="empty-state-text">No friends yet</div>
                </div>
            `;
        } else {
            friendsList = data.map(friend => {
                let balanceHtml = '';
                if (friend.balance > 0) {
                    balanceHtml = `<span class="balance-indicator owes-you">Owes you ${this.formatAmount(friend.balance)}</span>`;
                } else if (friend.balance < 0) {
                    balanceHtml = `<span class="balance-indicator you-owe">You owe ${this.formatAmount(Math.abs(friend.balance))}</span>`;
                }

                return `
                    <div class="list-item" data-friend-id="${friend.id}">
                        <div class="list-item-icon">👤</div>
                        <div class="list-item-content">
                            <div class="list-item-title">${friend.name}</div>
                            ${balanceHtml}
                        </div>
                    </div>
                `;
            }).join('');
        }

        return `
            <div class="screen-friends">
                <div class="section-header">
                    <h2 class="section-title">Friends</h2>
                    <button class="section-action" id="toggle-add-friend">
                        ${showAddForm ? 'Cancel' : '+ Add'}
                    </button>
                </div>
                ${addForm}
                ${friendsList}
            </div>
        `;
    },

    // -------------------------------------------------------------------------
    // History Screen
    // -------------------------------------------------------------------------

    history(events = null) {
        if (!events) {
            return '<div class="loading">Loading...</div>';
        }

        if (events.length === 0) {
            return `
                <div class="empty-state">
                    <div class="empty-state-icon">📜</div>
                    <div class="empty-state-text">No events yet</div>
                </div>
            `;
        }

        const eventItems = events.map(event => {
            const isNegative = ['expense', 'settlement_paid'].includes(event.type);
            const valueClass = isNegative ? 'negative' : 'positive';
            const prefix = isNegative ? '-' : '+';

            const date = new Date(event.event_date);
            const dateStr = date.toLocaleDateString('en-IN', {
                day: 'numeric',
                month: 'short'
            });

            return `
                <div class="list-item">
                    <div class="list-item-icon">${this.getEventIcon(event.type)}</div>
                    <div class="list-item-content">
                        <div class="list-item-title">
                            ${event.description || event.category || this.getEventTypeName(event.type)}
                        </div>
                        <div class="list-item-subtitle">
                            ${this.getEventTypeName(event.type)} • ${dateStr}
                        </div>
                    </div>
                    <div class="list-item-value ${valueClass}">
                        ${prefix}${this.formatAmount(event.amount)}
                    </div>
                </div>
            `;
        }).join('');

        return `
            <div class="screen-history">
                <div class="section-header">
                    <h2 class="section-title">History</h2>
                </div>
                ${eventItems}
            </div>
        `;
    },

    // -------------------------------------------------------------------------
    // Settings Screen (Modal)
    // -------------------------------------------------------------------------

    settings(data = null, categories = []) {
        if (!data) {
            return '<div class="loading">Loading...</div>';
        }

        const budgetRupees = data.base_budget / 100;
        const carryOverCapRupees = data.carry_over_cap ? data.carry_over_cap / 100 : '';

        // Generate reset day options (1-28)
        const resetDayOptions = Array.from({length: 28}, (_, i) => {
            const day = i + 1;
            const selected = day === data.budget_reset_day ? 'selected' : '';
            return `<option value="${day}" ${selected}>${day}</option>`;
        }).join('');

        // Generate category list HTML
        const categoryListHtml = categories.length > 0
            ? categories.map(cat => `
                <div class="category-item" data-category-id="${cat.id}" data-is-default="${cat.is_default}">
                    <span class="category-name">${cat.name}</span>
                    <span class="category-usage">${cat.usage_count || 0} events</span>
                    <div class="category-actions">
                        <button class="btn-icon edit-category" title="Edit">✏️</button>
                        ${!cat.is_default ? `<button class="btn-icon delete-category" title="Delete">🗑️</button>` : ''}
                    </div>
                </div>
            `).join('')
            : '<p class="text-muted">No categories</p>';

        return `
            <div class="modal-header">
                <h2 class="modal-title">Settings</h2>
                <button class="modal-close" id="close-settings">✕</button>
            </div>

            <div class="settings-tabs">
                <button class="settings-tab active" data-tab="general">General</button>
                <button class="settings-tab" data-tab="categories">Categories</button>
                <button class="settings-tab" data-tab="data">Data</button>
            </div>

            <!-- General Tab -->
            <div class="settings-tab-content active" id="tab-general">
                <form id="settings-form">
                    <div class="form-group">
                        <label class="form-label">Monthly Budget (₹)</label>
                        <input type="number" 
                               name="base_budget" 
                               class="form-input" 
                               value="${budgetRupees}"
                               step="100" 
                               min="0"
                               inputmode="numeric">
                        <span class="form-help">Your available spending limit each month</span>
                    </div>

                    <div class="settings-section">
                        <h3 class="settings-section-title">Budget Reset</h3>
                        
                        <div class="form-group">
                            <label class="form-label">Reset Day of Month</label>
                            <select name="budget_reset_day" class="form-input">
                                ${resetDayOptions}
                            </select>
                            <span class="form-help">Day when your budget resets (1-28)</span>
                        </div>
                    </div>

                    <div class="settings-section">
                        <h3 class="settings-section-title">Carry Over</h3>
                        
                        <div class="form-group">
                            <label class="form-checkbox">
                                <input type="checkbox" 
                                       name="carry_over_enabled" 
                                       ${data.carry_over_enabled ? 'checked' : ''}>
                                <span>Enable carry over</span>
                            </label>
                            <span class="form-help">Unused budget carries to next month</span>
                        </div>

                        <div class="form-group carry-over-options ${!data.carry_over_enabled ? 'hidden' : ''}">
                            <label class="form-label">Maximum Carry Over (₹)</label>
                            <input type="number" 
                                   name="carry_over_cap" 
                                   class="form-input" 
                                   value="${carryOverCapRupees}"
                                   placeholder="Leave empty for unlimited"
                                   step="100" 
                                   min="0"
                                   inputmode="numeric">
                            <span class="form-help">Maximum amount to carry over (empty = unlimited)</span>
                        </div>

                        <div class="form-group carry-over-options ${!data.carry_over_enabled ? 'hidden' : ''}">
                            <label class="form-checkbox">
                                <input type="checkbox" 
                                       name="carry_over_negative" 
                                       ${data.carry_over_negative ? 'checked' : ''}>
                                <span>Carry over deficits</span>
                            </label>
                            <span class="form-help">If you overspend, reduce next month's budget</span>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-block">
                        Save Settings
                    </button>
                </form>
            </div>

            <!-- Categories Tab -->
            <div class="settings-tab-content" id="tab-categories">
                <div class="category-add-form">
                    <input type="text" 
                           id="new-category-name" 
                           class="form-input" 
                           placeholder="New category name">
                    <button class="btn btn-primary" id="add-category-btn">Add</button>
                </div>
                
                <div class="category-list" id="category-list">
                    ${categoryListHtml}
                </div>
            </div>

            <!-- Data Tab -->
            <div class="settings-tab-content" id="tab-data">
                <div class="settings-section">
                    <h3 class="settings-section-title">Backup</h3>
                    <button class="btn btn-secondary btn-block" id="export-data">
                        📥 Export Data
                    </button>
                    <span class="form-help text-center mt-sm" style="display:block;">
                        Download your data as JSON for backup
                    </span>
                </div>

                <div class="settings-section mt-lg">
                    <h3 class="settings-section-title">Restore</h3>
                    <input type="file" id="import-file-input" accept=".json" style="display:none;">
                    <button class="btn btn-secondary btn-block" id="import-data-btn">
                        📤 Import Data
                    </button>
                    <span class="form-help text-center mt-sm" style="display:block;">
                        Restore from a JSON backup file (replaces all data)
                    </span>
                </div>

                <div class="settings-section mt-lg">
                    <h3 class="settings-section-title danger">Danger Zone</h3>
                    <button class="btn btn-danger btn-block" id="clear-data-btn">
                        🗑️ Clear All Data
                    </button>
                    <span class="form-help text-center mt-sm" style="display:block;">
                        Delete all transactions (keeps settings & categories)
                    </span>
                </div>
            </div>
        `;
    },

    // -------------------------------------------------------------------------
    // Clear Data Confirmation Modal
    // -------------------------------------------------------------------------

    clearDataConfirm() {
        return `
            <div class="modal-header">
                <h2 class="modal-title danger">⚠️ Clear All Data</h2>
                <button class="modal-close" id="close-clear-confirm">✕</button>
            </div>
            
            <div class="clear-data-warning">
                <p>This will permanently delete:</p>
                <ul>
                    <li>All transactions</li>
                    <li>All month records</li>
                </ul>
                <p>Your settings and categories will be kept.</p>
            </div>

            <div class="form-group">
                <label class="form-checkbox">
                    <input type="checkbox" id="keep-friends-checkbox" checked>
                    <span>Keep friends list</span>
                </label>
            </div>

            <div class="form-group">
                <label class="form-label">Type DELETE to confirm:</label>
                <input type="text" 
                       id="delete-confirm-input" 
                       class="form-input" 
                       placeholder="DELETE"
                       autocomplete="off">
            </div>

            <button class="btn btn-danger btn-block" id="confirm-clear-btn" disabled>
                Clear All Data
            </button>
        `;
    },

    // -------------------------------------------------------------------------
    // EMI Schedule Modal
    // -------------------------------------------------------------------------

    emiScheduleModal(loan, schedule = []) {
        const rows = schedule.length > 0
            ? schedule.map(e => `
                <div class="form-row emi-schedule-row">
                    <div class="form-group" style="flex:1;">
                        <input type="number" class="form-input emi-month-input" value="${e.month_number}" min="1" max="${loan.tenure_months}">
                    </div>
                    <div class="form-group" style="flex:1;">
                        <input type="number" class="form-input emi-amount-input" value="${e.emi_amount / 100}">
                    </div>
                </div>
            `).join('')
            : `
                <div class="form-row emi-schedule-row">
                    <div class="form-group" style="flex:1;">
                        <input type="number" class="form-input emi-month-input" placeholder="Month #" min="1" max="${loan.tenure_months}">
                    </div>
                    <div class="form-group" style="flex:1;">
                        <input type="number" class="form-input emi-amount-input" placeholder="EMI (₹)">
                    </div>
                </div>
            `;

        return `
            <div class="modal-header">
                <h2 class="modal-title">Variable EMI Schedule</h2>
                <button class="modal-close" id="close-emi-schedule">✕</button>
            </div>
            <p class="text-muted">Set custom EMI amounts for specific months. Months not listed use the default EMI of ${this.formatAmount(loan.emi_amount)}.</p>
            <div class="form-row" style="margin-bottom: 0.25rem;">
                <div style="flex:1; font-weight:bold; font-size:0.85rem;">Month #</div>
                <div style="flex:1; font-weight:bold; font-size:0.85rem;">EMI (₹)</div>
            </div>
            <div id="emi-schedule-edit-rows">
                ${rows}
            </div>
            <button type="button" class="btn btn-secondary btn-sm mt-sm" id="add-emi-edit-row-btn">+ Add Month</button>
            <div class="modal-actions mt-lg">
                <button type="button" class="btn btn-secondary" id="cancel-emi-schedule">Cancel</button>
                <button type="button" class="btn btn-primary" id="save-emi-schedule" data-loan-id="${loan.id}">Save Schedule</button>
            </div>
        `;
    },

    // -------------------------------------------------------------------------
    // Import Data Confirmation Modal
    // -------------------------------------------------------------------------

    importDataConfirm(fileName) {
        return `
            <div class="modal-header">
                <h2 class="modal-title danger">⚠️ Import Data</h2>
                <button class="modal-close" id="close-import-confirm">✕</button>
            </div>

            <div class="clear-data-warning">
                <p>This will <strong>replace all existing data</strong> with the backup from:</p>
                <p style="text-align:center; font-weight:bold; margin: 0.5rem 0;">${fileName}</p>
                <p>All current transactions, accounts, loans, and recurring items will be deleted first.</p>
            </div>

            <div class="form-group">
                <label class="form-label">Type IMPORT to confirm:</label>
                <input type="text"
                       id="import-confirm-input"
                       class="form-input"
                       placeholder="IMPORT"
                       autocomplete="off">
            </div>

            <button class="btn btn-danger btn-block" id="confirm-import-btn" disabled>
                Replace All Data
            </button>
        `;
    },

    // -------------------------------------------------------------------------
    // Category Edit Modal
    // -------------------------------------------------------------------------

    categoryEdit(category) {
        return `
            <div class="modal-header">
                <h2 class="modal-title">Edit Category</h2>
                <button class="modal-close" id="close-category-edit">✕</button>
            </div>
            
            <form id="category-edit-form">
                <input type="hidden" name="category_id" value="${category.id}">
                
                <div class="form-group">
                    <label class="form-label">Category Name</label>
                    <input type="text" 
                           name="name" 
                           class="form-input" 
                           value="${category.name}"
                           required>
                </div>

                <button type="submit" class="btn btn-primary btn-block">
                    Save Changes
                </button>
            </form>
        `;
    },

    // -------------------------------------------------------------------------
    // Category Delete Confirmation Modal
    // -------------------------------------------------------------------------

    categoryDeleteConfirm(category, categories) {
        // Filter out the category being deleted
        const otherCategories = categories.filter(c => c.id !== category.id);
        const options = otherCategories
            .map(c => `<option value="${c.name}">${c.name}</option>`)
            .join('');

        return `
            <div class="modal-header">
                <h2 class="modal-title">Delete Category</h2>
                <button class="modal-close" id="close-category-delete">✕</button>
            </div>
            
            <p>Delete category "<strong>${category.name}</strong>"?</p>
            
            ${category.usage_count > 0 ? `
                <div class="form-group">
                    <label class="form-label">Reassign ${category.usage_count} events to:</label>
                    <select id="reassign-category" class="form-input">
                        ${options}
                    </select>
                </div>
            ` : ''}

            <div class="modal-actions">
                <button class="btn btn-secondary" id="cancel-category-delete">Cancel</button>
                <button class="btn btn-danger" id="confirm-category-delete" data-category-id="${category.id}">
                    Delete
                </button>
            </div>
        `;
    },

    // -------------------------------------------------------------------------
    // Accounts Screen
    // -------------------------------------------------------------------------

    accounts(accounts = []) {
        const totalBalance = accounts.reduce((sum, acc) => {
            if (!acc.is_credit) return sum + (acc.current_balance || 0);
            return sum;
        }, 0);

        const accountsList = accounts.length > 0
            ? accounts.map(acc => `
                <div class="list-item account-item" data-account-id="${acc.id}">
                    <div class="list-item-icon">${this._getAccountIcon(acc.type)}</div>
                    <div class="list-item-content">
                        <div class="list-item-title">
                            ${acc.name}
                            ${acc.is_default ? '<span class="badge badge-small">Default</span>' : ''}
                        </div>
                        <div class="list-item-subtitle">
                            ${this._formatAccountType(acc.type)}${acc.institution ? ' • ' + acc.institution : ''}
                        </div>
                    </div>
                    <div class="list-item-value ${acc.current_balance >= 0 ? 'positive' : 'negative'}">
                        ${this.formatAmount(acc.current_balance || 0)}
                        ${acc.is_credit ? `<div class="credit-limit-small">/${this.formatAmount(acc.credit_limit || 0)}</div>` : ''}
                    </div>
                </div>
            `).join('')
            : '<div class="empty-state"><div class="empty-state-icon">🏦</div><div class="empty-state-text">No accounts yet</div></div>';

        return `
            <div class="screen-accounts">
                <div class="section-header">
                    <h2 class="section-title">Accounts</h2>
                    <button class="section-action" id="add-account-btn">+ Add</button>
                </div>
                
                <div class="summary-card-single mb-md">
                    <div class="summary-card-title">Total Balance</div>
                    <div class="summary-card-value ${totalBalance >= 0 ? 'positive' : 'negative'}">
                        ${this.formatAmount(totalBalance)}
                    </div>
                </div>

                <div class="accounts-list">
                    ${accountsList}
                </div>
            </div>
        `;
    },

    _getAccountIcon(type) {
        const icons = {
            'savings': '🏦',
            'current': '🏛️',
            'cash': '💵',
            'credit_card': '💳',
            'upi_wallet': '📱',
            'debit_card': '💳'
        };
        return icons[type] || '🏦';
    },

    _formatAccountType(type) {
        const types = {
            'savings': 'Savings',
            'current': 'Current',
            'cash': 'Cash',
            'credit_card': 'Credit Card',
            'upi_wallet': 'UPI/Wallet',
            'debit_card': 'Debit Card'
        };
        return types[type] || type;
    },

    addAccountModal() {
        return `
            <div class="modal-header">
                <h2 class="modal-title">Add Account</h2>
                <button class="modal-close" id="close-add-account">✕</button>
            </div>
            <form id="add-account-form">
                <div class="form-group">
                    <label class="form-label">Account Name</label>
                    <input type="text" name="name" class="form-input" placeholder="e.g., HDFC Savings" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Type</label>
                    <select name="type" class="form-input" id="account-type-select" required>
                        <option value="savings">🏦 Savings Account</option>
                        <option value="current">🏛️ Current Account</option>
                        <option value="cash">💵 Cash/Wallet</option>
                        <option value="credit_card">💳 Credit Card</option>
                        <option value="upi_wallet">📱 UPI/Digital Wallet</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Institution (Optional)</label>
                    <input type="text" name="institution" class="form-input" placeholder="e.g., HDFC Bank">
                </div>
                <div class="form-group">
                    <label class="form-label">Current Balance (₹)</label>
                    <input type="number" name="current_balance" class="form-input" value="0" step="1">
                </div>
                <div class="credit-card-fields hidden">
                    <div class="form-group">
                        <label class="form-label">Credit Limit (₹)</label>
                        <input type="number" name="credit_limit" class="form-input" placeholder="100000">
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Billing Day</label>
                            <input type="number" name="billing_day" class="form-input" min="1" max="28" placeholder="5">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Due Day</label>
                            <input type="number" name="due_day" class="form-input" min="1" max="28" placeholder="20">
                        </div>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-block">Add Account</button>
            </form>
        `;
    },

    // -------------------------------------------------------------------------
    // Recurring Screen
    // -------------------------------------------------------------------------

    recurring(transactions = [], pending = []) {
        const pendingHtml = pending.length > 0 ? `
            <div class="section mb-md">
                <div class="section-header-small">
                    <span class="section-icon">⏰</span>
                    <span>Pending Verification (${pending.length})</span>
                </div>
                ${pending.map(p => `
                    <div class="list-item pending-item" data-pending-id="${p.id}">
                        <div class="list-item-icon">⏳</div>
                        <div class="list-item-content">
                            <div class="list-item-title">${p.name}</div>
                            <div class="list-item-subtitle">Due: ${p.due_date}</div>
                        </div>
                        <div class="list-item-value">${this.formatAmount(p.amount)}</div>
                        <div class="pending-actions">
                            <button class="btn btn-sm btn-success confirm-pending-btn" title="Confirm paid">✓</button>
                            <button class="btn btn-sm btn-secondary skip-pending-btn" title="Skip">✗</button>
                        </div>
                    </div>
                `).join('')}
            </div>
        ` : '';

        const recurringHtml = transactions.length > 0
            ? transactions.map(r => {
                const autopayBadge = r.is_autopay ? '<span class="autopay-badge">🔄 Auto</span>' : '';
                const typeIcon = r.type === 'income' ? '💰' : (r.type === 'emi_payment' ? '🏠' : '📤');

                return `
                    <div class="list-item recurring-item" data-recurring-id="${r.id}">
                        <div class="list-item-icon">${typeIcon}</div>
                        <div class="list-item-content">
                            <div class="list-item-title">${r.name} ${autopayBadge}</div>
                            <div class="list-item-subtitle">
                                ${this._formatFrequency(r.frequency)} • Next: ${r.next_due_date || 'N/A'}
                            </div>
                        </div>
                        <div class="list-item-value ${r.type === 'income' ? 'positive' : 'negative'}">
                            ${r.type === 'income' ? '+' : '-'}${this.formatAmount(r.amount)}
                        </div>
                    </div>
                `;
            }).join('')
            : '<div class="empty-state"><div class="empty-state-icon">🔄</div><div class="empty-state-text">No recurring transactions</div></div>';

        return `
            <div class="screen-recurring">
                <div class="section-header">
                    <h2 class="section-title">Recurring</h2>
                    <button class="section-action" id="add-recurring-btn">+ Add</button>
                </div>
                ${pendingHtml}
                <div class="section">
                    <div class="section-header-small">
                        <span class="section-icon">🔄</span>
                        <span>Active Recurring</span>
                    </div>
                    ${recurringHtml}
                </div>
            </div>
        `;
    },

    _formatFrequency(freq) {
        const freqs = { daily: 'Daily', weekly: 'Weekly', monthly: 'Monthly', yearly: 'Yearly' };
        return freqs[freq] || freq;
    },

    addRecurringModal(categories = [], accounts = []) {
        const today = new Date().toISOString().split('T')[0];
        const categoryOptions = categories.map(c => `<option value="${c.name}">${c.name}</option>`).join('');
        const accountOptions = accounts.map(a => `<option value="${a.id}">${a.name}</option>`).join('');

        return `
            <div class="modal-header">
                <h2 class="modal-title">Add Recurring</h2>
                <button class="modal-close" id="close-add-recurring">✕</button>
            </div>
            <form id="add-recurring-form">
                <div class="form-group">
                    <label class="form-label">Name</label>
                    <input type="text" name="name" class="form-input" placeholder="e.g., Netflix" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Type</label>
                    <select name="type" class="form-input">
                        <option value="expense">Expense</option>
                        <option value="income">Income</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Amount (₹)</label>
                    <input type="number" name="amount" class="form-input" step="1" min="1" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Category</label>
                    <select name="category" class="form-input">
                        <option value="">Select category</option>
                        ${categoryOptions}
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Account (Optional)</label>
                    <select name="account_id" class="form-input">
                        <option value="">-- Select Account --</option>
                        ${accountOptions}
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Frequency</label>
                        <select name="frequency" class="form-input">
                            <option value="monthly">Monthly</option>
                            <option value="weekly">Weekly</option>
                            <option value="daily">Daily</option>
                            <option value="yearly">Yearly</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Day of Month</label>
                        <input type="number" name="day_of_month" class="form-input" min="1" max="28" value="1">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Start Date</label>
                    <input type="date" name="start_date" class="form-input" value="${today}" required>
                </div>
                <div class="form-group">
                    <label class="form-checkbox">
                        <input type="checkbox" name="is_autopay">
                        <span>Autopay (bank auto-deducts)</span>
                    </label>
                    <small class="form-help">Enable if payment is automatically deducted by bank/service</small>
                </div>
                <div class="form-group">
                    <label class="form-checkbox">
                        <input type="checkbox" name="requires_verification" checked>
                        <span>Requires verification</span>
                    </label>
                    <small class="form-help">You'll be notified when payment is due</small>
                </div>
                <button type="submit" class="btn btn-primary btn-block">Add Recurring</button>
            </form>
        `;
    },

    // -------------------------------------------------------------------------
    // More Screen (Menu)
    // -------------------------------------------------------------------------

    more() {
        return `
            <div class="screen-more">
                <div class="section-header">
                    <h2 class="section-title">More</h2>
                </div>
                
                <div class="menu-list">
                    <div class="menu-item" data-screen="history">
                        <span class="menu-icon">📜</span>
                        <span class="menu-label">Transaction History</span>
                        <span class="menu-arrow">›</span>
                    </div>
                    <div class="menu-item" data-screen="friends">
                        <span class="menu-icon">👥</span>
                        <span class="menu-label">Friends</span>
                        <span class="menu-arrow">›</span>
                    </div>
                    <div class="menu-item" data-screen="loans">
                        <span class="menu-icon">🏠</span>
                        <span class="menu-label">Loans & EMIs</span>
                        <span class="menu-arrow">›</span>
                    </div>
                    <div class="menu-item" data-screen="creditcards">
                        <span class="menu-icon">💳</span>
                        <span class="menu-label">Credit Cards</span>
                        <span class="menu-arrow">›</span>
                    </div>
                </div>
            </div>
        `;
    },

    // -------------------------------------------------------------------------
    // Loans Screen
    // -------------------------------------------------------------------------

    loans(loans = []) {
        const totalEmi = loans.reduce((sum, l) => sum + (l.is_active ? l.emi_amount : 0), 0);

        const loansHtml = loans.length > 0
            ? loans.map(l => {
                const progress = Math.round((l.payments_made / l.tenure_months) * 100);
                return `
                    <div class="list-item loan-item ${!l.is_active ? 'inactive' : ''}" data-loan-id="${l.id}">
                        <div class="loan-info">
                            <div class="list-item-title">${l.name}</div>
                            <div class="list-item-subtitle">
                                ${l.lender || 'Unknown'} • ${l.payments_made}/${l.tenure_months} EMIs
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: ${progress}%"></div>
                            </div>
                        </div>
                        <div class="loan-amount">
                            <div class="emi-amount">${this.formatAmount(l.emi_amount)}/mo</div>
                            <div class="outstanding-small">Left: ${this.formatAmount(l.outstanding)}</div>
                        </div>
                    </div>
                `;
            }).join('')
            : '<div class="empty-state"><div class="empty-state-icon">🏠</div><div class="empty-state-text">No loans</div></div>';

        return `
            <div class="screen-loans">
                <div class="section-header">
                    <h2 class="section-title">Loans & EMIs</h2>
                    <button class="section-action" id="add-loan-btn">+ Add</button>
                </div>
                
                <div class="summary-card-single mb-md">
                    <div class="summary-card-title">Total Monthly EMI</div>
                    <div class="summary-card-value negative">${this.formatAmount(totalEmi)}</div>
                </div>

                <div class="loans-list">
                    ${loansHtml}
                </div>
            </div>
        `;
    },

    addLoanModal(accounts = []) {
        const today = new Date().toISOString().split('T')[0];
        const accountOptions = accounts.map(a => `<option value="${a.id}">${a.name}</option>`).join('');

        return `
            <div class="modal-header">
                <h2 class="modal-title">Add Loan</h2>
                <button class="modal-close" id="close-add-loan">✕</button>
            </div>
            <form id="add-loan-form">
                <div class="form-group">
                    <label class="form-label">Loan Name</label>
                    <input type="text" name="name" class="form-input" placeholder="e.g., Home Loan" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Type</label>
                    <select name="type" class="form-input">
                        <option value="home_loan">🏠 Home Loan</option>
                        <option value="car_loan">🚗 Car Loan</option>
                        <option value="personal_loan">💰 Personal Loan</option>
                        <option value="credit_card_emi">💳 Credit Card EMI</option>
                        <option value="bnpl">🛒 Buy Now Pay Later</option>
                        <option value="other">📋 Other</option>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Principal (₹)</label>
                        <input type="number" name="principal" class="form-input" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Interest (%/yr)</label>
                        <input type="number" name="interest_rate" class="form-input" step="0.01" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Tenure (months)</label>
                        <input type="number" name="tenure_months" class="form-input" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">EMI (₹)</label>
                        <input type="number" name="emi_amount" class="form-input" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">EMI Day</label>
                        <input type="number" name="emi_day" class="form-input" min="1" max="28" value="5">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Start Date</label>
                        <input type="date" name="start_date" class="form-input" value="${today}" required>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-checkbox">
                        <input type="checkbox" id="variable-emi-toggle">
                        <span>Variable EMI (step-up/step-down)</span>
                    </label>
                    <span class="form-help">Different EMI amounts per month</span>
                </div>
                <div id="variable-emi-section" style="display:none;">
                    <div class="form-help mb-sm">Enter EMI amounts for months that differ from the default. Unlisted months use the default EMI above.</div>
                    <div id="emi-schedule-rows">
                        <div class="form-row emi-schedule-row">
                            <div class="form-group" style="flex:1;">
                                <input type="number" class="form-input emi-month-input" placeholder="Month #" min="1">
                            </div>
                            <div class="form-group" style="flex:1;">
                                <input type="number" class="form-input emi-amount-input" placeholder="EMI (₹)">
                            </div>
                        </div>
                    </div>
                    <button type="button" class="btn btn-secondary btn-sm" id="add-emi-row-btn">+ Add Month</button>
                </div>
                <div class="form-group">
                    <label class="form-label">Lender (Optional)</label>
                    <input type="text" name="lender" class="form-input" placeholder="e.g., HDFC Bank">
                </div>
                <div class="form-group">
                    <label class="form-label">Payment Account</label>
                    <select name="payment_account_id" class="form-input">
                        <option value="">-- Select Account --</option>
                        ${accountOptions}
                    </select>
                </div>
                <button type="submit" class="btn btn-primary btn-block">Add Loan</button>
            </form>
        `;
    },

    // -------------------------------------------------------------------------
    // Credit Cards Screen
    // -------------------------------------------------------------------------

    creditCards(cards = []) {
        const cardsHtml = cards.length > 0
            ? cards.map(card => `
                <div class="credit-card-item" data-card-id="${card.id}">
                    <div class="card-header">
                        <span class="card-name">${card.name}</span>
                        <span class="card-institution">${card.institution || ''}</span>
                    </div>
                    <div class="card-stats">
                        <div class="card-stat">
                            <div class="stat-label">Outstanding</div>
                            <div class="stat-value danger">${this.formatAmount(card.outstanding || 0)}</div>
                        </div>
                        <div class="card-stat">
                            <div class="stat-label">Available</div>
                            <div class="stat-value success">${this.formatAmount(card.available_limit || 0)}</div>
                        </div>
                        <div class="card-stat">
                            <div class="stat-label">Limit</div>
                            <div class="stat-value">${this.formatAmount(card.credit_limit || 0)}</div>
                        </div>
                    </div>
                    <div class="utilization-bar">
                        <div class="utilization-fill ${(card.utilization_percent || 0) > 70 ? 'high' : ''}" 
                             style="width: ${Math.min(100, card.utilization_percent || 0)}%"></div>
                    </div>
                    <div class="card-footer">
                        <span>Bill: ${card.billing_day || '-'}th</span>
                        <span>Due: ${card.due_day || '-'}th</span>
                        <button class="btn btn-sm btn-primary pay-card-btn">Pay</button>
                    </div>
                </div>
            `).join('')
            : '<div class="empty-state"><div class="empty-state-icon">💳</div><div class="empty-state-text">No credit cards<br><small>Add one from Accounts screen</small></div></div>';

        return `
            <div class="screen-credit-cards">
                <div class="section-header">
                    <h2 class="section-title">Credit Cards</h2>
                </div>
                <div class="credit-cards-list">
                    ${cardsHtml}
                </div>
            </div>
        `;
    },

    payCardModal(card, accounts = []) {
        const accountOptions = accounts
            .filter(a => a.type !== 'credit_card')
            .map(a => `<option value="${a.id}">${a.name}</option>`)
            .join('');

        return `
            <div class="modal-header">
                <h2 class="modal-title">Pay ${card.name}</h2>
                <button class="modal-close" id="close-pay-card">✕</button>
            </div>
            <div class="card-balance-info">
                <div>Outstanding: <strong>${this.formatAmount(card.outstanding || 0)}</strong></div>
            </div>
            <form id="pay-card-form">
                <input type="hidden" name="card_id" value="${card.id}">
                <div class="form-group">
                    <label class="form-label">Amount (₹)</label>
                    <input type="number" name="amount" class="form-input" value="${(card.outstanding || 0) / 100}" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Pay From</label>
                    <select name="from_account_id" class="form-input" required>
                        <option value="">Select account</option>
                        ${accountOptions}
                    </select>
                </div>
                <button type="submit" class="btn btn-primary btn-block">Pay Now</button>
            </form>
        `;
    },

    // -------------------------------------------------------------------------
    // Transfer Modal
    // -------------------------------------------------------------------------

    transferModal(accounts = []) {
        const accountOptions = accounts.map(a => `<option value="${a.id}">${a.name}</option>`).join('');

        return `
            <div class="modal-header">
                <h2 class="modal-title">Transfer Money</h2>
                <button class="modal-close" id="close-transfer">✕</button>
            </div>
            <form id="transfer-form">
                <div class="form-group">
                    <label class="form-label">From Account</label>
                    <select name="from_account_id" class="form-input" required>
                        <option value="">Select account</option>
                        ${accountOptions}
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">To Account</label>
                    <select name="to_account_id" class="form-input" required>
                        <option value="">Select account</option>
                        ${accountOptions}
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Amount (₹)</label>
                    <input type="number" name="amount" class="form-input" step="1" min="1" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Description (Optional)</label>
                    <input type="text" name="description" class="form-input" placeholder="Transfer note">
                </div>
                <button type="submit" class="btn btn-primary btn-block">Transfer</button>
            </form>
        `;
    },

    // -------------------------------------------------------------------------
    // View/Edit Recurring Modal
    // -------------------------------------------------------------------------

    viewRecurringModal(recurring, categories = [], accounts = []) {
        const categoryOptions = categories.map(c =>
            `<option value="${c.name}" ${c.name === recurring.category ? 'selected' : ''}>${c.name}</option>`
        ).join('');

        const accountOptions = accounts.map(a =>
            `<option value="${a.id}" ${a.id === recurring.account_id ? 'selected' : ''}>${a.name}</option>`
        ).join('');

        const frequencyOptions = ['daily', 'weekly', 'monthly', 'yearly'].map(f =>
            `<option value="${f}" ${f === recurring.frequency ? 'selected' : ''}>${f.charAt(0).toUpperCase() + f.slice(1)}</option>`
        ).join('');

        return `
            <div class="modal-header">
                <h2 class="modal-title">${recurring.name}</h2>
                <button class="modal-close" id="close-view-recurring">✕</button>
            </div>
            
            <div class="detail-summary">
                <div class="detail-amount ${recurring.type === 'income' ? 'positive' : 'negative'}">
                    ${recurring.type === 'income' ? '+' : '-'}${this.formatAmount(recurring.amount)}
                </div>
                <div class="detail-meta">
                    ${this._formatFrequency(recurring.frequency)} • ${recurring.is_active ? 'Active' : 'Inactive'}
                </div>
                <div class="detail-meta">
                    Next: ${recurring.next_due_date || 'N/A'}
                </div>
            </div>

            <form id="edit-recurring-form">
                <input type="hidden" name="id" value="${recurring.id}">
                
                <div class="form-group">
                    <label class="form-label">Name</label>
                    <input type="text" name="name" class="form-input" value="${recurring.name}" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Amount (₹)</label>
                    <input type="number" name="amount" class="form-input" value="${recurring.amount / 100}" step="1" min="1" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Category</label>
                    <select name="category" class="form-input">
                        <option value="">Select category</option>
                        ${categoryOptions}
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Account</label>
                    <select name="account_id" class="form-input">
                        <option value="">-- Select Account --</option>
                        ${accountOptions}
                    </select>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Frequency</label>
                        <select name="frequency" class="form-input">
                            ${frequencyOptions}
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Day of Month</label>
                        <input type="number" name="day_of_month" class="form-input" min="1" max="28" value="${recurring.day_of_month || 1}">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-checkbox">
                        <input type="checkbox" name="requires_verification" ${recurring.requires_verification ? 'checked' : ''}>
                        <span>Requires verification</span>
                    </label>
                </div>
                
                <div class="form-group">
                    <label class="form-checkbox">
                        <input type="checkbox" name="is_active" ${recurring.is_active ? 'checked' : ''}>
                        <span>Active</span>
                    </label>
                </div>
                
                <div class="modal-actions">
                    <button type="button" class="btn btn-danger" id="delete-recurring-btn">Delete</button>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </form>
        `;
    },

    // -------------------------------------------------------------------------
    // View/Edit Loan Modal
    // -------------------------------------------------------------------------

    viewLoanModal(loan, accounts = []) {
        const accountOptions = accounts.map(a =>
            `<option value="${a.id}" ${a.id === loan.payment_account_id ? 'selected' : ''}>${a.name}</option>`
        ).join('');

        const progress = Math.round((loan.payments_made / loan.tenure_months) * 100);
        const totalPaid = loan.payments_made * loan.emi_amount;
        const totalAmount = loan.tenure_months * loan.emi_amount;

        return `
            <div class="modal-header">
                <h2 class="modal-title">${loan.name}</h2>
                <button class="modal-close" id="close-view-loan">✕</button>
            </div>
            
            <div class="loan-detail-summary">
                <div class="loan-progress-section">
                    <div class="progress-bar large">
                        <div class="progress-fill" style="width: ${progress}%"></div>
                    </div>
                    <div class="progress-labels">
                        <span>${loan.payments_made} of ${loan.tenure_months} EMIs paid</span>
                        <span>${progress}%</span>
                    </div>
                </div>
                
                <div class="loan-stats-grid">
                    <div class="loan-stat">
                        <div class="stat-label">Principal</div>
                        <div class="stat-value">${this.formatAmount(loan.principal)}</div>
                    </div>
                    <div class="loan-stat">
                        <div class="stat-label">Interest Rate</div>
                        <div class="stat-value">${loan.interest_rate}%</div>
                    </div>
                    <div class="loan-stat">
                        <div class="stat-label">EMI</div>
                        <div class="stat-value">${this.formatAmount(loan.emi_amount)}</div>
                    </div>
                    <div class="loan-stat">
                        <div class="stat-label">Outstanding</div>
                        <div class="stat-value danger">${this.formatAmount(loan.outstanding)}</div>
                    </div>
                    <div class="loan-stat">
                        <div class="stat-label">Total Paid</div>
                        <div class="stat-value success">${this.formatAmount(loan.total_paid)}</div>
                    </div>
                    <div class="loan-stat">
                        <div class="stat-label">EMI Day</div>
                        <div class="stat-value">${loan.emi_day}th</div>
                    </div>
                </div>
            </div>

            <div class="section-divider"></div>

            <h3 class="section-subtitle">EMI Schedule</h3>
            <div id="loan-emi-schedule-section">
                ${loan.has_custom_schedule
                    ? '<p class="text-muted">This loan has a variable EMI schedule.</p>'
                    : '<p class="text-muted">Using fixed EMI of ' + this.formatAmount(loan.emi_amount) + '/month.</p>'
                }
                <div class="modal-actions" style="margin-top: 0.5rem;">
                    <button type="button" class="btn btn-secondary btn-sm" id="view-amortization-btn" data-loan-id="${loan.id}">
                        View Amortization
                    </button>
                    <button type="button" class="btn btn-secondary btn-sm" id="manage-emi-schedule-btn" data-loan-id="${loan.id}">
                        ${loan.has_custom_schedule ? 'Edit Schedule' : 'Set Variable EMI'}
                    </button>
                    ${loan.has_custom_schedule ? `
                        <button type="button" class="btn btn-danger btn-sm" id="revert-fixed-emi-btn" data-loan-id="${loan.id}">
                            Revert to Fixed
                        </button>
                    ` : ''}
                </div>
            </div>

            <div class="section-divider"></div>

            <h3 class="section-subtitle">Edit Details</h3>

            <form id="edit-loan-form">
                <input type="hidden" name="id" value="${loan.id}">
                
                <div class="form-group">
                    <label class="form-label">Loan Name</label>
                    <input type="text" name="name" class="form-input" value="${loan.name}" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">EMI Amount (₹)</label>
                        <input type="number" name="emi_amount" class="form-input" value="${loan.emi_amount / 100}" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">EMI Day</label>
                        <input type="number" name="emi_day" class="form-input" min="1" max="28" value="${loan.emi_day}">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Lender</label>
                    <input type="text" name="lender" class="form-input" value="${loan.lender || ''}">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Payment Account</label>
                    <select name="payment_account_id" class="form-input">
                        <option value="">-- Select Account --</option>
                        ${accountOptions}
                    </select>
                </div>
                
                <div class="modal-actions">
                    <button type="button" class="btn btn-danger" id="close-loan-btn">Close Loan</button>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </form>
        `;
    },

    // -------------------------------------------------------------------------
    // Budget Breakdown Modal
    // -------------------------------------------------------------------------

    budgetBreakdownModal(data) {
        const calc = data.calculation;
        const breakdown = data.breakdown;

        return `
            <div class="modal-header">
                <h2 class="modal-title">Budget Breakdown</h2>
                <button class="modal-close" id="close-budget-breakdown">✕</button>
            </div>
            
            <div class="budget-breakdown">
                <div class="breakdown-item">
                    <span class="breakdown-label">Base Budget</span>
                    <span class="breakdown-value">${this.formatAmount(calc.starting)}</span>
                </div>
                
                ${calc.plus_carry_over > 0 ? `
                <div class="breakdown-item positive">
                    <span class="breakdown-label">+ Carry Over</span>
                    <span class="breakdown-value">+${this.formatAmount(calc.plus_carry_over)}</span>
                </div>
                ` : ''}
                
                ${calc.plus_adjustments > 0 ? `
                <div class="breakdown-item positive">
                    <span class="breakdown-label">+ Adjustments</span>
                    <span class="breakdown-value">+${this.formatAmount(calc.plus_adjustments)}</span>
                </div>
                ` : ''}
                
                ${calc.plus_settlements_received > 0 ? `
                <div class="breakdown-item positive">
                    <span class="breakdown-label">+ Settlements Received</span>
                    <span class="breakdown-value">+${this.formatAmount(calc.plus_settlements_received)}</span>
                </div>
                ` : ''}
                
                ${calc.minus_expenses > 0 ? `
                <div class="breakdown-item negative">
                    <span class="breakdown-label">− Expenses</span>
                    <span class="breakdown-value">-${this.formatAmount(calc.minus_expenses)}</span>
                </div>
                ` : ''}
                
                ${(calc.minus_emi_payments || 0) > 0 ? `
                <div class="breakdown-item negative">
                    <span class="breakdown-label">− EMI/Loan Payments</span>
                    <span class="breakdown-value">-${this.formatAmount(calc.minus_emi_payments)}</span>
                </div>
                ` : ''}
                
                ${calc.minus_liabilities > 0 ? `
                <div class="breakdown-item negative">
                    <span class="breakdown-label">− Outstanding Liabilities</span>
                    <span class="breakdown-value">-${this.formatAmount(calc.minus_liabilities)}</span>
                </div>
                ` : ''}
                
                ${(calc.minus_unpaid_recurring || 0) > 0 ? `
                <div class="breakdown-item negative">
                    <span class="breakdown-label">− Unpaid Bills (reserved)</span>
                    <span class="breakdown-value">-${this.formatAmount(calc.minus_unpaid_recurring)}</span>
                </div>
                ` : ''}
                
                <div class="breakdown-divider"></div>
                
                <div class="breakdown-item total ${calc.equals_remaining >= 0 ? 'positive' : 'negative'}">
                    <span class="breakdown-label"><strong>= Remaining</strong></span>
                    <span class="breakdown-value"><strong>${this.formatAmount(calc.equals_remaining)}</strong></span>
                </div>
            </div>
            
            ${data.unpaid_recurring_items && data.unpaid_recurring_items.length > 0 ? `
            <div class="breakdown-details">
                <h4>📋 Upcoming Bills (Reserved)</h4>
                <div class="detail-grid">
                    ${data.unpaid_recurring_items.map(item => `
                    <div class="detail-item ${item.is_overdue ? 'overdue' : ''}">
                        <span>${item.name} ${item.is_autopay ? '🔄' : ''}</span>
                        <span class="negative">-${this.formatAmount(item.amount)}</span>
                    </div>
                    `).join('')}
                </div>
            </div>
            ` : ''}
            
            <div class="breakdown-details">
                <h4>Details</h4>
                <div class="detail-grid">
                    <div class="detail-item">
                        <span>Income this month</span>
                        <span class="positive">+${this.formatAmount(breakdown.income)}</span>
                    </div>
                    ${(breakdown.emi_payments || 0) > 0 ? `
                    <div class="detail-item">
                        <span>EMI/Loan Payments</span>
                        <span class="negative">-${this.formatAmount(breakdown.emi_payments)}</span>
                    </div>
                    ` : ''}
                    <div class="detail-item">
                        <span>Settlements Paid</span>
                        <span>${this.formatAmount(breakdown.settlements_paid)}</span>
                    </div>
                    <div class="detail-item">
                        <span>Net Liabilities</span>
                        <span class="negative">${this.formatAmount(breakdown.net_liabilities)}</span>
                    </div>
                </div>
            </div>
        `;
    },

    // -------------------------------------------------------------------------
    // Friend Detail Modal
    // -------------------------------------------------------------------------

    viewFriendModal(friend, balance, events = []) {
        const balanceClass = balance > 0 ? 'positive' : (balance < 0 ? 'negative' : '');
        const balanceText = balance > 0
            ? `Owes you ${this.formatAmount(balance)}`
            : (balance < 0 ? `You owe ${this.formatAmount(Math.abs(balance))}` : 'Settled');

        const eventsHtml = events.length > 0
            ? events.map(e => {
                const date = new Date(e.event_date);
                const dateStr = date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });
                const isNegative = ['liability', 'settlement_paid'].includes(e.type);

                return `
                    <div class="list-item mini">
                        <div class="list-item-icon">${this.getEventIcon(e.type)}</div>
                        <div class="list-item-content">
                            <div class="list-item-title">${e.description || this.getEventTypeName(e.type)}</div>
                            <div class="list-item-subtitle">${dateStr}</div>
                        </div>
                        <div class="list-item-value ${isNegative ? 'negative' : 'positive'}">
                            ${isNegative ? '-' : '+'}${this.formatAmount(e.amount)}
                        </div>
                    </div>
                `;
            }).join('')
            : '<div class="empty-state-small">No transactions</div>';

        const canDelete = balance === 0;

        return `
            <div class="modal-header">
                <h2 class="modal-title">👤 ${friend.name}</h2>
                <button class="modal-close" id="close-view-friend">✕</button>
            </div>
            
            <div class="friend-detail-summary">
                <div class="balance-display ${balanceClass}">
                    ${balanceText}
                </div>
                ${friend.phone ? `<div class="friend-phone">📞 ${friend.phone}</div>` : ''}
            </div>
            
            <div class="section-divider"></div>
            
            <h4>Edit Details</h4>
            <form id="edit-friend-form">
                <input type="hidden" name="id" value="${friend.id}">
                <div class="form-group">
                    <label class="form-label">Name</label>
                    <input type="text" name="name" class="form-input" value="${friend.name}" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Phone (optional)</label>
                    <input type="tel" name="phone" class="form-input" value="${friend.phone || ''}" placeholder="Phone number">
                </div>
                <button type="submit" class="btn btn-primary btn-block">Save Changes</button>
            </form>
            
            <div class="section-divider"></div>
            
            <h4>Transaction History</h4>
            <div class="friend-events-list">
                ${eventsHtml}
            </div>
            
            <div class="section-divider"></div>
            
            <button class="btn btn-danger btn-block" id="delete-friend-btn" 
                    data-friend-id="${friend.id}" ${!canDelete ? 'disabled' : ''}>
                🗑️ Delete Friend
            </button>
            ${!canDelete ? '<p class="text-muted text-center mt-sm">Settle balance to delete</p>' : ''}
        `;
    },

    // -------------------------------------------------------------------------
    // Account Detail Modal
    // -------------------------------------------------------------------------

    viewAccountModal(account, events = []) {
        const balanceClass = account.current_balance >= 0 ? 'positive' : 'negative';

        const eventsHtml = events.length > 0
            ? events.slice(0, 20).map(e => {
                const date = new Date(e.event_date);
                const dateStr = date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });
                const isCredit = ['income', 'settlement_received', 'transfer'].includes(e.type) && e.to_account_id === account.id;
                const isDebit = ['expense', 'settlement_paid', 'transfer', 'emi_payment'].includes(e.type) &&
                               (e.account_id === account.id || e.from_account_id === account.id);

                const valueClass = isCredit ? 'positive' : 'negative';
                const prefix = isCredit ? '+' : '-';

                return `
                    <div class="list-item mini">
                        <div class="list-item-icon">${this.getEventIcon(e.type)}</div>
                        <div class="list-item-content">
                            <div class="list-item-title">${e.description || e.category || this.getEventTypeName(e.type)}</div>
                            <div class="list-item-subtitle">${dateStr}</div>
                        </div>
                        <div class="list-item-value ${valueClass}">
                            ${prefix}${this.formatAmount(e.amount)}
                        </div>
                    </div>
                `;
            }).join('')
            : '<div class="empty-state-small">No transactions</div>';

        const canDelete = !account.is_default;

        return `
            <div class="modal-header">
                <h2 class="modal-title">${this._getAccountIcon(account.type)} ${account.name}</h2>
                <button class="modal-close" id="close-view-account">✕</button>
            </div>
            
            <div class="account-detail-summary">
                <div class="balance-display ${balanceClass}">
                    ${this.formatAmount(account.current_balance || 0)}
                </div>
                <div class="account-meta">
                    ${this._formatAccountType(account.type)}
                    ${account.institution ? ' • ' + account.institution : ''}
                </div>
                ${account.is_credit ? `
                    <div class="credit-info">
                        <span>Limit: ${this.formatAmount(account.credit_limit || 0)}</span>
                        <span>Billing: ${account.billing_day || '-'}th</span>
                        <span>Due: ${account.due_day || '-'}th</span>
                    </div>
                ` : ''}
            </div>
            
            <div class="section-divider"></div>
            
            <h4>Edit Details</h4>
            <form id="edit-account-form">
                <input type="hidden" name="id" value="${account.id}">
                <div class="form-group">
                    <label class="form-label">Account Name</label>
                    <input type="text" name="name" class="form-input" value="${account.name}" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Institution</label>
                    <input type="text" name="institution" class="form-input" value="${account.institution || ''}">
                </div>
                <div class="form-group">
                    <label class="form-label">Current Balance (₹)</label>
                    <input type="number" name="current_balance" class="form-input" value="${(account.current_balance || 0) / 100}">
                </div>
                ${account.is_credit ? `
                    <div class="form-group">
                        <label class="form-label">Credit Limit (₹)</label>
                        <input type="number" name="credit_limit" class="form-input" value="${(account.credit_limit || 0) / 100}">
                    </div>
                ` : ''}
                <button type="submit" class="btn btn-primary btn-block">Save Changes</button>
            </form>
            
            <div class="section-divider"></div>
            
            <h4>Recent Transactions</h4>
            <div class="account-events-list">
                ${eventsHtml}
            </div>
            
            ${canDelete ? `
                <div class="section-divider"></div>
                <button class="btn btn-danger btn-block" id="delete-account-btn" data-account-id="${account.id}">
                    🗑️ Delete Account
                </button>
            ` : ''}
        `;
    },

    // -------------------------------------------------------------------------
    // History Screen with Timeline Filter
    // -------------------------------------------------------------------------

    historyWithFilter(events = [], isDetailedMode = false) {
        const filterHtml = `
            <div class="history-filter">
                <button class="filter-btn ${!isDetailedMode ? 'active' : ''}" data-detailed="false">
                    💰 Money Only
                </button>
                <button class="filter-btn ${isDetailedMode ? 'active' : ''}" data-detailed="true">
                    📋 Full Activity
                </button>
            </div>
        `;

        if (events.length === 0) {
            return `
                <div class="screen-history">
                    <div class="section-header">
                        <h2 class="section-title">History</h2>
                    </div>
                    ${filterHtml}
                    <div class="empty-state">
                        <div class="empty-state-icon">📜</div>
                        <div class="empty-state-text">No activity yet</div>
                    </div>
                </div>
            `;
        }

        const eventItems = events.map(item => {
            if (item.type === 'audit') {
                // Audit log entry
                const actionIcons = {
                    create: '➕',
                    update: '✏️',
                    delete: '🗑️',
                    close: '🔒'
                };
                const icon = actionIcons[item.action] || '📝';

                return `
                    <div class="list-item audit-item">
                        <div class="list-item-icon">${icon}</div>
                        <div class="list-item-content">
                            <div class="list-item-title">${item.description || `${item.action} ${item.entity_type}`}</div>
                            <div class="list-item-subtitle">
                                ${item.entity_type} • ${item.date}
                            </div>
                        </div>
                    </div>
                `;
            } else {
                // Regular event
                const isNegative = ['expense', 'settlement_paid', 'emi_payment', 'transfer'].includes(item.event_type);
                const valueClass = isNegative ? 'negative' : 'positive';
                const prefix = isNegative ? '-' : '+';

                return `
                    <div class="list-item">
                        <div class="list-item-icon">${this.getEventIcon(item.event_type)}</div>
                        <div class="list-item-content">
                            <div class="list-item-title">
                                ${item.description || item.category || this.getEventTypeName(item.event_type)}
                            </div>
                            <div class="list-item-subtitle">
                                ${this.getEventTypeName(item.event_type)} • ${item.date}
                            </div>
                        </div>
                        <div class="list-item-value ${valueClass}">
                            ${prefix}${this.formatAmount(item.amount)}
                        </div>
                    </div>
                `;
            }
        }).join('');

        return `
            <div class="screen-history">
                <div class="section-header">
                    <h2 class="section-title">History</h2>
                </div>
                ${filterHtml}
                <div class="history-list">
                    ${eventItems}
                </div>
            </div>
        `;
    }
};

