/**
 * MoneyTrace Main Application
 *
 * Handles navigation, form submissions, and screen management.
 * Business logic stays in Python backend - this just coordinates UI.
 */

const App = {
    currentScreen: 'dashboard',
    showAddFriendForm: false,

    // -------------------------------------------------------------------------
    // Initialization
    // -------------------------------------------------------------------------

    init() {
        this.bindNavigation();
        this.bindSettingsButton();
        this.showScreen('dashboard');
        this.registerServiceWorker();
    },

    registerServiceWorker() {
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/sw.js')
                .then(() => console.log('SW registered'))
                .catch(err => console.log('SW registration failed:', err));
        }
    },

    // -------------------------------------------------------------------------
    // Navigation
    // -------------------------------------------------------------------------

    bindNavigation() {
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const screen = btn.dataset.screen;
                this.showScreen(screen);
            });
        });
    },

    updateNavActive(screenName) {
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.screen === screenName);
        });
    },

    async showScreen(screenName) {
        this.currentScreen = screenName;
        this.updateNavActive(screenName);

        const main = document.getElementById('main-content');

        switch (screenName) {
            case 'dashboard':
                await this.loadDashboard(main);
                break;
            case 'add':
                await this.loadAddEvent(main);
                break;
            case 'friends':
                await this.loadFriends(main);
                break;
            case 'history':
                await this.loadHistory(main);
                break;
        }
    },

    // -------------------------------------------------------------------------
    // Dashboard
    // -------------------------------------------------------------------------

    async loadDashboard(container) {
        container.innerHTML = Screens.dashboard(null);

        try {
            const data = await API.getDashboard();
            container.innerHTML = Screens.dashboard(data);
            this.bindDashboardHandlers();
        } catch (err) {
            container.innerHTML = `
                <div class="card">
                    <p class="text-center text-muted">Failed to load dashboard</p>
                    <p class="text-center text-muted">${err.message}</p>
                </div>
            `;
        }
    },

    bindDashboardHandlers() {
        // Handle clicking on friend items to view details
        document.querySelectorAll('.friend-balance-item').forEach(item => {
            item.addEventListener('click', () => {
                const friendId = item.dataset.friendId;
                if (friendId) {
                    this.showFriendDetails(friendId);
                }
            });
        });
    },

    async showFriendDetails(friendId) {
        try {
            const data = await API.getFriendDetails(friendId);
            this.showFriendModal(data);
        } catch (err) {
            this.showToast('Failed to load friend details', 'error');
        }
    },

    showFriendModal(data) {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'friend-modal';

        const balanceClass = data.balance >= 0 ? 'positive' : 'negative';
        const balanceText = data.balance >= 0
            ? `Owes you ₹${Math.abs(data.balance / 100).toLocaleString('en-IN')}`
            : `You owe ₹${Math.abs(data.balance / 100).toLocaleString('en-IN')}`;

        const eventsHtml = data.events && data.events.length > 0
            ? data.events.map(e => `
                <div class="list-item">
                    <div class="list-item-icon">${Screens.getEventIcon(e.type)}</div>
                    <div class="list-item-content">
                        <div class="list-item-title">${e.description || e.category || Screens.getEventTypeName(e.type)}</div>
                        <div class="list-item-subtitle">${Screens.getEventTypeName(e.type)} • ${new Date(e.event_date).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })}</div>
                    </div>
                    <div class="list-item-value">₹${(e.amount / 100).toLocaleString('en-IN')}</div>
                </div>
            `).join('')
            : '<p class="text-center text-muted">No transactions yet</p>';

        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.innerHTML = `
            <div class="modal-header">
                <h2 class="modal-title">${data.friend.name}</h2>
                <button class="modal-close" id="close-friend-modal">✕</button>
            </div>
            <div class="friend-modal-balance ${balanceClass}">
                ${balanceText}
            </div>
            <div class="section-header-small mt-md">
                <span>Transaction History</span>
            </div>
            <div class="friend-events-list">
                ${eventsHtml}
            </div>
        `;

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Close handlers
        document.getElementById('close-friend-modal').addEventListener('click', () => overlay.remove());
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });
    },

    // -------------------------------------------------------------------------
    // Add Event
    // -------------------------------------------------------------------------

    async loadAddEvent(container) {
        container.innerHTML = '<div class="loading">Loading...</div>';

        try {
            const [categories, friends] = await Promise.all([
                API.getCategoryList(),
                API.getFriends()
            ]);

            container.innerHTML = Screens.addEvent(categories, friends);
            this.bindAddEventHandlers();
        } catch (err) {
            container.innerHTML = Screens.addEvent([], []);
            this.bindAddEventHandlers();
        }
    },

    bindAddEventHandlers() {
        // Type selector
        document.querySelectorAll('.type-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.type-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');

                const type = btn.dataset.type;
                document.querySelector('input[name="type"]').value = type;

                // Show/hide friend selector
                const friendGroup = document.getElementById('friend-group');
                const friendSelect = document.querySelector('select[name="friend_id"]');

                if (type === 'liability' || type === 'receivable') {
                    friendGroup.classList.remove('hidden');
                    friendSelect.required = true;
                } else {
                    friendGroup.classList.add('hidden');
                    friendSelect.required = false;
                }
            });
        });

        // Form submission
        const form = document.getElementById('event-form');
        if (form) {
            form.addEventListener('submit', async (e) => {
                e.preventDefault();
                await this.handleAddEvent(form);
            });
        }
    },

    async handleAddEvent(form) {
        const formData = new FormData(form);
        const submitBtn = form.querySelector('button[type="submit"]');

        // Convert amount to paise
        const amountRupees = parseFloat(formData.get('amount'));
        const amountPaise = Math.round(amountRupees * 100);

        const event = {
            type: formData.get('type'),
            amount: amountPaise,
            category: formData.get('category') || null,
            description: formData.get('description') || null,
            friend_id: formData.get('friend_id') || null,
            event_date: formData.get('event_date') || null
        };

        // Remove null values
        Object.keys(event).forEach(k => event[k] === null && delete event[k]);

        try {
            submitBtn.disabled = true;
            submitBtn.textContent = 'Adding...';

            await API.createEvent(event);

            this.showToast('Event added!', 'success');
            form.reset();
            document.querySelector('input[name="type"]').value = 'expense';

            // Go to dashboard after short delay
            setTimeout(() => this.showScreen('dashboard'), 500);
        } catch (err) {
            this.showToast('Error: ' + err.message, 'error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Add Event';
        }
    },

    // -------------------------------------------------------------------------
    // Friends
    // -------------------------------------------------------------------------

    async loadFriends(container) {
        container.innerHTML = Screens.friends(null);

        try {
            const friends = await API.getFriends();
            container.innerHTML = Screens.friends(friends, this.showAddFriendForm);
            this.bindFriendsHandlers();
        } catch (err) {
            container.innerHTML = `
                <div class="card">
                    <p class="text-center text-muted">Failed to load friends</p>
                </div>
            `;
        }
    },

    bindFriendsHandlers() {
        // Toggle add form
        const toggleBtn = document.getElementById('toggle-add-friend');
        if (toggleBtn) {
            toggleBtn.addEventListener('click', () => {
                this.showAddFriendForm = !this.showAddFriendForm;
                this.loadFriends(document.getElementById('main-content'));
            });
        }

        // Add friend form
        const form = document.getElementById('add-friend-form');
        if (form) {
            form.addEventListener('submit', async (e) => {
                e.preventDefault();
                await this.handleAddFriend(form);
            });
        }
    },

    async handleAddFriend(form) {
        const formData = new FormData(form);
        const submitBtn = form.querySelector('button[type="submit"]');

        try {
            submitBtn.disabled = true;
            submitBtn.textContent = 'Adding...';

            await API.createFriend({
                name: formData.get('name'),
                phone: formData.get('phone') || null
            });

            this.showToast('Friend added!', 'success');
            this.showAddFriendForm = false;
            this.loadFriends(document.getElementById('main-content'));
        } catch (err) {
            this.showToast('Error: ' + err.message, 'error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Add Friend';
        }
    },

    // -------------------------------------------------------------------------
    // History
    // -------------------------------------------------------------------------

    async loadHistory(container) {
        container.innerHTML = Screens.history(null);

        try {
            const events = await API.getEvents(50);
            container.innerHTML = Screens.history(events);
        } catch (err) {
            container.innerHTML = `
                <div class="card">
                    <p class="text-center text-muted">Failed to load history</p>
                </div>
            `;
        }
    },

    // -------------------------------------------------------------------------
    // Settings Modal
    // -------------------------------------------------------------------------

    bindSettingsButton() {
        const settingsBtn = document.getElementById('settings-btn');
        if (settingsBtn) {
            settingsBtn.addEventListener('click', () => this.showSettings());
        }
    },

    async showSettings() {
        // Create modal overlay
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'settings-modal';

        const modal = document.createElement('div');
        modal.className = 'modal modal-large';
        modal.innerHTML = Screens.settings(null);

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Load settings and categories
        try {
            const [settings, categories] = await Promise.all([
                API.getSettings(),
                API.getCategories()
            ]);
            this.currentSettings = settings;
            this.currentCategories = categories;
            modal.innerHTML = Screens.settings(settings, categories);
            this.bindSettingsHandlers(overlay, modal);
        } catch (err) {
            modal.innerHTML = `<p class="text-center text-muted">Failed to load settings</p>`;
        }

        // Close on overlay click
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) {
                this.closeSettings();
            }
        });
    },

    closeSettings() {
        const modal = document.getElementById('settings-modal');
        if (modal) {
            modal.remove();
        }
    },

    bindSettingsHandlers(overlay, modal) {
        // Close button
        const closeBtn = document.getElementById('close-settings');
        if (closeBtn) {
            closeBtn.addEventListener('click', () => this.closeSettings());
        }

        // Tab switching
        document.querySelectorAll('.settings-tab').forEach(tab => {
            tab.addEventListener('click', () => {
                // Update active tab
                document.querySelectorAll('.settings-tab').forEach(t => t.classList.remove('active'));
                tab.classList.add('active');

                // Show corresponding content
                const tabName = tab.dataset.tab;
                document.querySelectorAll('.settings-tab-content').forEach(content => {
                    content.classList.toggle('active', content.id === `tab-${tabName}`);
                });
            });
        });

        // Carry over toggle
        const carryOverCheckbox = document.querySelector('input[name="carry_over_enabled"]');
        if (carryOverCheckbox) {
            carryOverCheckbox.addEventListener('change', () => {
                document.querySelectorAll('.carry-over-options').forEach(el => {
                    el.classList.toggle('hidden', !carryOverCheckbox.checked);
                });
            });
        }

        // Settings form
        const form = document.getElementById('settings-form');
        if (form) {
            form.addEventListener('submit', async (e) => {
                e.preventDefault();
                await this.handleSaveSettings(form);
            });
        }

        // Export button
        const exportBtn = document.getElementById('export-data');
        if (exportBtn) {
            exportBtn.addEventListener('click', () => this.handleExport());
        }

        // Clear data button
        const clearDataBtn = document.getElementById('clear-data-btn');
        if (clearDataBtn) {
            clearDataBtn.addEventListener('click', () => this.showClearDataConfirm(modal));
        }

        // Add category
        const addCategoryBtn = document.getElementById('add-category-btn');
        if (addCategoryBtn) {
            addCategoryBtn.addEventListener('click', () => this.handleAddCategory(modal));
        }

        // Enter key on category input
        const newCategoryInput = document.getElementById('new-category-name');
        if (newCategoryInput) {
            newCategoryInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    this.handleAddCategory(modal);
                }
            });
        }

        // Category edit/delete buttons
        this.bindCategoryItemHandlers(modal);
    },

    bindCategoryItemHandlers(modal) {
        document.querySelectorAll('.edit-category').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                const item = btn.closest('.category-item');
                const categoryId = item.dataset.categoryId;
                const category = this.currentCategories.find(c => c.id === categoryId);
                if (category) {
                    this.showCategoryEditModal(modal, category);
                }
            });
        });

        document.querySelectorAll('.delete-category').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                const item = btn.closest('.category-item');
                const categoryId = item.dataset.categoryId;
                const category = this.currentCategories.find(c => c.id === categoryId);
                if (category) {
                    this.showCategoryDeleteConfirm(modal, category);
                }
            });
        });
    },

    async handleSaveSettings(form) {
        const formData = new FormData(form);
        const submitBtn = form.querySelector('button[type="submit"]');

        const budgetRupees = parseFloat(formData.get('base_budget'));
        const budgetPaise = Math.round(budgetRupees * 100);

        const budgetResetDay = parseInt(formData.get('budget_reset_day'));
        const carryOverEnabled = formData.get('carry_over_enabled') === 'on';
        const carryOverCapRupees = formData.get('carry_over_cap');
        const carryOverCapPaise = carryOverCapRupees ? Math.round(parseFloat(carryOverCapRupees) * 100) : 0;
        const carryOverNegative = formData.get('carry_over_negative') === 'on';

        try {
            submitBtn.disabled = true;
            submitBtn.textContent = 'Saving...';

            await API.updateSettings({
                base_budget: budgetPaise,
                budget_reset_day: budgetResetDay,
                carry_over_enabled: carryOverEnabled,
                carry_over_cap: carryOverCapPaise,
                carry_over_negative: carryOverNegative
            });

            this.showToast('Settings saved!', 'success');
            this.closeSettings();

            // Refresh dashboard if currently showing
            if (this.currentScreen === 'dashboard') {
                this.showScreen('dashboard');
            }
        } catch (err) {
            this.showToast('Error: ' + err.message, 'error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Save Settings';
        }
    },

    async handleExport() {
        try {
            const data = await API.exportData();
            const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);

            const a = document.createElement('a');
            a.href = url;
            a.download = `moneytrace-backup-${new Date().toISOString().split('T')[0]}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);

            this.showToast('Data exported!', 'success');
        } catch (err) {
            this.showToast('Export failed: ' + err.message, 'error');
        }
    },

    // -------------------------------------------------------------------------
    // Category Management
    // -------------------------------------------------------------------------

    async handleAddCategory(modal) {
        const input = document.getElementById('new-category-name');
        const name = input.value.trim();

        if (!name) {
            this.showToast('Please enter a category name', 'error');
            return;
        }

        try {
            await API.addCategory(name);
            input.value = '';

            // Refresh categories
            this.currentCategories = await API.getCategories();
            this.refreshCategoryList();
            this.showToast('Category added!', 'success');
        } catch (err) {
            this.showToast('Error: ' + err.message, 'error');
        }
    },

    refreshCategoryList() {
        const list = document.getElementById('category-list');
        if (!list) return;

        const categoryListHtml = this.currentCategories.length > 0
            ? this.currentCategories.map(cat => `
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

        list.innerHTML = categoryListHtml;

        // Re-bind handlers
        const modal = document.querySelector('.modal');
        this.bindCategoryItemHandlers(modal);
    },

    showCategoryEditModal(parentModal, category) {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'category-edit-modal';

        const modal = document.createElement('div');
        modal.className = 'modal modal-small';
        modal.innerHTML = Screens.categoryEdit(category);

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Bind handlers
        document.getElementById('close-category-edit').addEventListener('click', () => {
            overlay.remove();
        });

        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });

        document.getElementById('category-edit-form').addEventListener('submit', async (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            const categoryId = formData.get('category_id');
            const newName = formData.get('name').trim();

            if (!newName) {
                this.showToast('Please enter a category name', 'error');
                return;
            }

            try {
                await API.updateCategory(categoryId, newName);
                overlay.remove();

                // Refresh categories
                this.currentCategories = await API.getCategories();
                this.refreshCategoryList();
                this.showToast('Category updated!', 'success');
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
            }
        });
    },

    showCategoryDeleteConfirm(parentModal, category) {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'category-delete-modal';

        const modal = document.createElement('div');
        modal.className = 'modal modal-small';
        modal.innerHTML = Screens.categoryDeleteConfirm(category, this.currentCategories);

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Bind handlers
        document.getElementById('close-category-delete').addEventListener('click', () => {
            overlay.remove();
        });

        document.getElementById('cancel-category-delete').addEventListener('click', () => {
            overlay.remove();
        });

        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });

        document.getElementById('confirm-category-delete').addEventListener('click', async () => {
            const reassignSelect = document.getElementById('reassign-category');
            const reassignTo = reassignSelect ? reassignSelect.value : 'Other';

            try {
                await API.deleteCategory(category.id, reassignTo);
                overlay.remove();

                // Refresh categories
                this.currentCategories = await API.getCategories();
                this.refreshCategoryList();
                this.showToast('Category deleted!', 'success');
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
            }
        });
    },

    // -------------------------------------------------------------------------
    // Clear Data
    // -------------------------------------------------------------------------

    showClearDataConfirm(parentModal) {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'clear-data-modal';

        const modal = document.createElement('div');
        modal.className = 'modal modal-small';
        modal.innerHTML = Screens.clearDataConfirm();

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Bind handlers
        document.getElementById('close-clear-confirm').addEventListener('click', () => {
            overlay.remove();
        });

        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });

        // Enable confirm button only when "DELETE" is typed
        const confirmInput = document.getElementById('delete-confirm-input');
        const confirmBtn = document.getElementById('confirm-clear-btn');

        confirmInput.addEventListener('input', () => {
            confirmBtn.disabled = confirmInput.value !== 'DELETE';
        });

        confirmBtn.addEventListener('click', async () => {
            const keepFriends = document.getElementById('keep-friends-checkbox').checked;

            try {
                confirmBtn.disabled = true;
                confirmBtn.textContent = 'Clearing...';

                await API.clearData(keepFriends);
                overlay.remove();
                this.closeSettings();

                this.showToast('All data cleared!', 'success');

                // Refresh current screen
                this.showScreen(this.currentScreen);
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
                confirmBtn.disabled = false;
                confirmBtn.textContent = 'Clear All Data';
            }
        });
    },

    // -------------------------------------------------------------------------
    // Toast Notifications
    // -------------------------------------------------------------------------

    showToast(message, type = 'info') {
        // Simple alert for now - can enhance later
        alert(message);
    }
};

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => App.init());

// Export for debugging
window.App = App;

