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
                        </div>
                    </div>
                </div>

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

    addEvent(categories = [], friends = []) {
        const today = new Date().toISOString().split('T')[0];

        const categoryOptions = categories
            .map(c => `<option value="${c.name}">${c.name}</option>`)
            .join('');

        const friendOptions = friends
            .map(f => `<option value="${f.id}">${f.name}</option>`)
            .join('');

        return `
            <div class="screen-add">
                <!-- Event Type Selector -->
                <div class="type-selector">
                    <button class="type-btn active" data-type="expense">
                        <span class="type-btn-icon">💸</span>
                        Expense
                    </button>
                    <button class="type-btn" data-type="liability">
                        <span class="type-btn-icon">📤</span>
                        I Owe
                    </button>
                    <button class="type-btn" data-type="receivable">
                        <span class="type-btn-icon">📥</span>
                        Owes Me
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
                        <label class="form-label">Friend</label>
                        <select name="friend_id" class="form-input">
                            <option value="">Select friend</option>
                            ${friendOptions}
                        </select>
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
    }
};

