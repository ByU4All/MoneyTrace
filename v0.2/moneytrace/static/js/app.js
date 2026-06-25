/**
 * MoneyTrace Main Application
 *
 * Handles navigation, form submissions, and screen management.
 * Business logic stays in Python backend - this just coordinates UI.
 */

const App = {
    currentScreen: 'dashboard',
    showAddFriendForm: false,
    currentAccounts: [],
    currentCategories: [],

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
            case 'accounts':
                await this.loadAccounts(main);
                break;
            case 'recurring':
                await this.loadRecurring(main);
                break;
            case 'more':
                await this.loadMore(main);
                break;
            case 'loans':
                await this.loadLoans(main);
                break;
            case 'creditcards':
                await this.loadCreditCards(main);
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
        // Handle clicking on budget card to show breakdown
        const budgetCard = document.querySelector('.budget-card');
        if (budgetCard) {
            budgetCard.style.cursor = 'pointer';
            budgetCard.addEventListener('click', () => {
                this.showBudgetBreakdown();
            });
        }

        // Handle clicking on friend items to view details
        document.querySelectorAll('.friend-balance-item').forEach(item => {
            item.addEventListener('click', () => {
                const friendId = item.dataset.friendId;
                if (friendId) {
                    this.showFriendDetailsModal(friendId);
                }
            });
        });
    },

    async showBudgetBreakdown() {
        try {
            const data = await API.getBudgetBreakdown();
            this.showBudgetBreakdownModal(data);
        } catch (err) {
            this.showToast('Failed to load breakdown', 'error');
        }
    },

    showBudgetBreakdownModal(data) {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'budget-breakdown-modal';

        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.innerHTML = Screens.budgetBreakdownModal(data);

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Close handlers
        document.getElementById('close-budget-breakdown').addEventListener('click', () => overlay.remove());
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });
    },

    async showFriendDetailsModal(friendId) {
        try {
            const data = await API.getFriendDetails(friendId);
            const overlay = document.createElement('div');
            overlay.className = 'modal-overlay';
            overlay.id = 'friend-modal';

            const modal = document.createElement('div');
            modal.className = 'modal modal-large';
            modal.innerHTML = Screens.viewFriendModal(data.friend, data.balance, data.events);

            overlay.appendChild(modal);
            document.body.appendChild(overlay);

            this.bindFriendModalHandlers(overlay, data.friend.id);
        } catch (err) {
            this.showToast('Failed to load friend details', 'error');
        }
    },

    bindFriendModalHandlers(overlay, friendId) {
        // Close handler
        document.getElementById('close-view-friend').addEventListener('click', () => overlay.remove());
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });

        // Edit form
        const editForm = document.getElementById('edit-friend-form');
        if (editForm) {
            editForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                const formData = new FormData(editForm);
                try {
                    await API.updateFriend(friendId, {
                        name: formData.get('name'),
                        phone: formData.get('phone') || null
                    });
                    this.showToast('Friend updated!', 'success');
                    overlay.remove();
                    this.showScreen(this.currentScreen);
                } catch (err) {
                    this.showToast('Error: ' + err.message, 'error');
                }
            });
        }

        // Delete button
        const deleteBtn = document.getElementById('delete-friend-btn');
        if (deleteBtn && !deleteBtn.disabled) {
            deleteBtn.addEventListener('click', async () => {
                if (confirm('Delete this friend?')) {
                    try {
                        await API.deleteFriend(friendId);
                        this.showToast('Friend deleted!', 'success');
                        overlay.remove();
                        this.showScreen(this.currentScreen);
                    } catch (err) {
                        this.showToast('Error: ' + err.message, 'error');
                    }
                }
            });
        }
    },

    // -------------------------------------------------------------------------
    // Add Event
    // -------------------------------------------------------------------------

    async loadAddEvent(container) {
        container.innerHTML = '<div class="loading">Loading...</div>';

        try {
            const [categories, friends, accounts] = await Promise.all([
                API.getCategoryList(),
                API.getFriends(),
                API.getAccounts()
            ]);

            container.innerHTML = Screens.addEvent(categories, friends, accounts);
            this.bindAddEventHandlers();
        } catch (err) {
            container.innerHTML = Screens.addEvent([], [], []);
            this.bindAddEventHandlers();
        }
    },

    bindAddEventHandlers() {
        const accountLabel = document.getElementById('account-label');
        const accountHelp = document.getElementById('account-help');
        const categoryGroup = document.getElementById('category-group');
        const categorySelect = document.querySelector('select[name="category"]');
        const accountGroup = document.getElementById('account-group');
        const transferGroup = document.getElementById('transfer-group');
        const friendGroup = document.getElementById('friend-group');
        const friendSelect = document.querySelector('select[name="friend_id"]');
        const settlementDirectionGroup = document.getElementById('settlement-direction-group');

        // Type selector - handles all event types
        document.querySelectorAll('.type-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.type-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');

                let type = btn.dataset.type;

                // Handle settlement - need to show direction selector
                if (type === 'settlement') {
                    settlementDirectionGroup.classList.remove('hidden');
                    type = 'settlement_paid'; // Default to paying
                    document.querySelector('input[name="type"]').value = type;
                } else {
                    settlementDirectionGroup.classList.add('hidden');
                    document.querySelector('input[name="type"]').value = type;
                }

                // Show/hide friend selector for friend-related types
                if (type === 'liability' || type === 'receivable' ||
                    type === 'settlement_paid' || type === 'settlement_received' ||
                    type === 'settlement') {
                    friendGroup.classList.remove('hidden');
                    friendSelect.required = true;
                } else {
                    friendGroup.classList.add('hidden');
                    friendSelect.required = false;
                }

                // Show/hide transfer group for transfers
                if (type === 'transfer') {
                    accountGroup.classList.add('hidden');
                    transferGroup.classList.remove('hidden');
                    categoryGroup.classList.add('hidden');
                    categorySelect.required = false;
                } else {
                    accountGroup.classList.remove('hidden');
                    transferGroup.classList.add('hidden');
                }

                // Update labels and visibility based on type
                if (type === 'expense') {
                    accountLabel.textContent = 'Paid From';
                    accountHelp.textContent = 'Which account was used for payment?';
                    categoryGroup.classList.remove('hidden');
                    categorySelect.required = true;
                } else if (type === 'income') {
                    accountLabel.textContent = 'Deposit To';
                    accountHelp.textContent = 'Which account received the money?';
                    categoryGroup.classList.remove('hidden');
                    categorySelect.required = true;
                } else if (type === 'liability') {
                    accountLabel.textContent = 'Account (Optional)';
                    accountHelp.textContent = 'Friend paid - no account deducted';
                    categoryGroup.classList.remove('hidden');
                    categorySelect.required = true;
                } else if (type === 'receivable') {
                    accountLabel.textContent = 'Paid From';
                    accountHelp.textContent = 'You paid for friend from this account';
                    categoryGroup.classList.remove('hidden');
                    categorySelect.required = true;
                } else if (type === 'settlement_paid' || type === 'settlement') {
                    accountLabel.textContent = 'Paid From';
                    accountHelp.textContent = 'Account used to pay back friend';
                    categoryGroup.classList.add('hidden');
                    categorySelect.required = false;
                } else if (type === 'settlement_received') {
                    accountLabel.textContent = 'Received To';
                    accountHelp.textContent = 'Account where friend paid you';
                    categoryGroup.classList.add('hidden');
                    categorySelect.required = false;
                }
            });
        });

        // Settlement direction toggle
        document.querySelectorAll('.settlement-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.settlement-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');

                const direction = btn.dataset.direction;
                const type = direction === 'paid' ? 'settlement_paid' : 'settlement_received';
                document.querySelector('input[name="type"]').value = type;

                // Update label
                if (direction === 'paid') {
                    accountLabel.textContent = 'Paid From';
                    accountHelp.textContent = 'Account used to pay back friend';
                } else {
                    accountLabel.textContent = 'Received To';
                    accountHelp.textContent = 'Account where friend paid you';
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
        const eventType = formData.get('type');

        // Convert amount to paise
        const amountRupees = parseFloat(formData.get('amount'));
        const amountPaise = Math.round(amountRupees * 100);

        // Handle transfer differently
        if (eventType === 'transfer') {
            const fromAccountId = formData.get('from_account_id');
            const toAccountId = formData.get('to_account_id');

            if (!fromAccountId || !toAccountId) {
                this.showToast('Please select both accounts', 'error');
                return;
            }

            if (fromAccountId === toAccountId) {
                this.showToast('Cannot transfer to same account', 'error');
                return;
            }

            try {
                submitBtn.disabled = true;
                submitBtn.textContent = 'Processing...';

                await API.createTransfer(
                    fromAccountId,
                    toAccountId,
                    amountPaise,
                    formData.get('description') || null
                );

                this.showToast('Transfer complete!', 'success');
                form.reset();
                document.querySelector('input[name="type"]').value = 'expense';
                setTimeout(() => this.showScreen('dashboard'), 500);
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
            } finally {
                submitBtn.disabled = false;
                submitBtn.textContent = 'Add Event';
            }
            return;
        }

        const event = {
            type: eventType,
            amount: amountPaise,
            category: formData.get('category') || null,
            description: formData.get('description') || null,
            friend_id: formData.get('friend_id') || null,
            account_id: formData.get('account_id') || null,
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

        // Click on friend item to view details
        document.querySelectorAll('.list-item[data-friend-id]').forEach(item => {
            item.style.cursor = 'pointer';
            item.addEventListener('click', () => {
                const friendId = item.dataset.friendId;
                if (friendId) {
                    this.showFriendDetailsModal(friendId);
                }
            });
        });
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

    historyDetailedMode: false,

    async loadHistory(container) {
        container.innerHTML = '<div class="loading">Loading...</div>';

        try {
            if (this.historyDetailedMode) {
                // Detailed mode - get timeline with audit trail
                const data = await API.getTimeline(100, true);
                container.innerHTML = Screens.historyWithFilter(data.timeline, true);
            } else {
                // Money only mode - get events
                const data = await API.getTimeline(100, false);
                container.innerHTML = Screens.historyWithFilter(data.timeline, false);
            }
            this.bindHistoryHandlers();
        } catch (err) {
            container.innerHTML = `
                <div class="card">
                    <p class="text-center text-muted">Failed to load history</p>
                </div>
            `;
        }
    },

    bindHistoryHandlers() {
        // Filter buttons
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const detailed = btn.dataset.detailed === 'true';
                this.historyDetailedMode = detailed;
                this.loadHistory(document.getElementById('main-content'));
            });
        });
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

        // Import data button
        const importBtn = document.getElementById('import-data-btn');
        const importFileInput = document.getElementById('import-file-input');
        if (importBtn && importFileInput) {
            importBtn.addEventListener('click', () => importFileInput.click());
            importFileInput.addEventListener('change', (e) => {
                const file = e.target.files[0];
                if (file) {
                    this.showImportDataConfirm(modal, file);
                    importFileInput.value = '';
                }
            });
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
    // Import Data
    // -------------------------------------------------------------------------

    showImportDataConfirm(parentModal, file) {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'import-data-modal';

        const modal = document.createElement('div');
        modal.className = 'modal modal-small';
        modal.innerHTML = Screens.importDataConfirm(file.name);

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Bind handlers
        document.getElementById('close-import-confirm').addEventListener('click', () => {
            overlay.remove();
        });

        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });

        // Enable confirm button only when "IMPORT" is typed
        const confirmInput = document.getElementById('import-confirm-input');
        const confirmBtn = document.getElementById('confirm-import-btn');

        confirmInput.addEventListener('input', () => {
            confirmBtn.disabled = confirmInput.value !== 'IMPORT';
        });

        confirmBtn.addEventListener('click', async () => {
            try {
                confirmBtn.disabled = true;
                confirmBtn.textContent = 'Importing...';

                await API.importData(file);
                overlay.remove();
                this.closeSettings();

                this.showToast('Data imported successfully!', 'success');

                // Refresh current screen
                this.showScreen(this.currentScreen);
            } catch (err) {
                this.showToast('Import failed: ' + err.message, 'error');
                confirmBtn.disabled = false;
                confirmBtn.textContent = 'Replace All Data';
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
    // Accounts
    // -------------------------------------------------------------------------

    async loadAccounts(container) {
        container.innerHTML = '<div class="loading">Loading...</div>';

        try {
            const accounts = await API.getAccounts();
            this.currentAccounts = accounts;
            container.innerHTML = Screens.accounts(accounts);
            this.bindAccountsHandlers();
        } catch (err) {
            container.innerHTML = `<div class="card"><p class="text-center text-muted">Failed to load accounts</p></div>`;
        }
    },

    bindAccountsHandlers() {
        const addBtn = document.getElementById('add-account-btn');
        if (addBtn) {
            addBtn.addEventListener('click', () => this.showAddAccountModal());
        }

        // Click on account item for details
        document.querySelectorAll('.account-item').forEach(item => {
            item.style.cursor = 'pointer';
            item.addEventListener('click', () => {
                const accountId = item.dataset.accountId;
                if (accountId) {
                    this.showAccountDetailsModal(accountId);
                }
            });
        });
    },

    async showAccountDetailsModal(accountId) {
        try {
            const [account, events] = await Promise.all([
                API.getAccount(accountId),
                API.getAccountEvents(accountId, 30)
            ]);

            const overlay = document.createElement('div');
            overlay.className = 'modal-overlay';
            overlay.id = 'account-modal';

            const modal = document.createElement('div');
            modal.className = 'modal modal-large';
            modal.innerHTML = Screens.viewAccountModal(account, events);

            overlay.appendChild(modal);
            document.body.appendChild(overlay);

            this.bindAccountModalHandlers(overlay, account);
        } catch (err) {
            this.showToast('Failed to load account details', 'error');
        }
    },

    bindAccountModalHandlers(overlay, account) {
        // Close handler
        document.getElementById('close-view-account').addEventListener('click', () => overlay.remove());
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });

        // Edit form
        const editForm = document.getElementById('edit-account-form');
        if (editForm) {
            editForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                const formData = new FormData(editForm);

                const updates = {
                    name: formData.get('name'),
                    institution: formData.get('institution') || null,
                    current_balance: Math.round(parseFloat(formData.get('current_balance') || 0) * 100),
                };

                if (account.is_credit && formData.get('credit_limit')) {
                    updates.credit_limit = Math.round(parseFloat(formData.get('credit_limit')) * 100);
                }

                try {
                    await API.updateAccount(account.id, updates);
                    this.showToast('Account updated!', 'success');
                    overlay.remove();
                    this.loadAccounts(document.getElementById('main-content'));
                } catch (err) {
                    this.showToast('Error: ' + err.message, 'error');
                }
            });
        }

        // Delete button
        const deleteBtn = document.getElementById('delete-account-btn');
        if (deleteBtn) {
            deleteBtn.addEventListener('click', async () => {
                if (confirm('Delete this account? Past transactions will be preserved.')) {
                    try {
                        await API.deleteAccount(account.id);
                        this.showToast('Account deleted!', 'success');
                        overlay.remove();
                        this.loadAccounts(document.getElementById('main-content'));
                    } catch (err) {
                        this.showToast('Error: ' + err.message, 'error');
                    }
                }
            });
        }
    },

    showAddAccountModal() {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'add-account-modal';

        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.innerHTML = Screens.addAccountModal();

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Close handlers
        document.getElementById('close-add-account').addEventListener('click', () => overlay.remove());
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });

        // Show/hide credit card fields
        const typeSelect = document.getElementById('account-type-select');
        typeSelect.addEventListener('change', () => {
            const ccFields = document.querySelector('.credit-card-fields');
            ccFields.classList.toggle('hidden', typeSelect.value !== 'credit_card');
        });

        // Form submission
        document.getElementById('add-account-form').addEventListener('submit', async (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            const submitBtn = e.target.querySelector('button[type="submit"]');

            const account = {
                name: formData.get('name'),
                type: formData.get('type'),
                institution: formData.get('institution') || null,
                current_balance: Math.round(parseFloat(formData.get('current_balance') || 0) * 100),
            };

            if (account.type === 'credit_card') {
                account.credit_limit = Math.round(parseFloat(formData.get('credit_limit') || 0) * 100);
                account.billing_day = parseInt(formData.get('billing_day')) || null;
                account.due_day = parseInt(formData.get('due_day')) || null;
            }

            try {
                submitBtn.disabled = true;
                submitBtn.textContent = 'Adding...';

                await API.createAccount(account);
                overlay.remove();
                this.showToast('Account added!', 'success');
                this.loadAccounts(document.getElementById('main-content'));
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Add Account';
            }
        });
    },

    // -------------------------------------------------------------------------
    // Recurring
    // -------------------------------------------------------------------------

    async loadRecurring(container) {
        container.innerHTML = '<div class="loading">Loading...</div>';

        try {
            const [recurring, pending] = await Promise.all([
                API.getRecurring(),
                API.getPendingTransactions()
            ]);
            container.innerHTML = Screens.recurring(recurring, pending);
            this.bindRecurringHandlers();
        } catch (err) {
            container.innerHTML = `<div class="card"><p class="text-center text-muted">Failed to load recurring</p></div>`;
        }
    },

    bindRecurringHandlers() {
        const addBtn = document.getElementById('add-recurring-btn');
        if (addBtn) {
            addBtn.addEventListener('click', () => this.showAddRecurringModal());
        }

        // Confirm pending
        document.querySelectorAll('.confirm-pending-btn').forEach(btn => {
            btn.addEventListener('click', async (e) => {
                e.stopPropagation();
                const item = btn.closest('.pending-item');
                const pendingId = item.dataset.pendingId;
                try {
                    await API.confirmPending(pendingId);
                    this.showToast('Transaction confirmed!', 'success');
                    this.loadRecurring(document.getElementById('main-content'));
                } catch (err) {
                    this.showToast('Error: ' + err.message, 'error');
                }
            });
        });

        // Skip pending
        document.querySelectorAll('.skip-pending-btn').forEach(btn => {
            btn.addEventListener('click', async (e) => {
                e.stopPropagation();
                const item = btn.closest('.pending-item');
                const pendingId = item.dataset.pendingId;
                try {
                    await API.skipPending(pendingId);
                    this.showToast('Transaction skipped', 'success');
                    this.loadRecurring(document.getElementById('main-content'));
                } catch (err) {
                    this.showToast('Error: ' + err.message, 'error');
                }
            });
        });

        // Click on recurring item to view/edit
        document.querySelectorAll('.recurring-item').forEach(item => {
            item.addEventListener('click', () => {
                const recurringId = item.dataset.recurringId;
                if (recurringId) {
                    this.showViewRecurringModal(recurringId);
                }
            });
        });
    },

    async showViewRecurringModal(recurringId) {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'view-recurring-modal';

        const modal = document.createElement('div');
        modal.className = 'modal modal-large';
        modal.innerHTML = '<div class="loading">Loading...</div>';

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        try {
            const [recurring, categories, accounts] = await Promise.all([
                API.getRecurringById(recurringId),
                API.getCategoryList(),
                API.getAccounts()
            ]);

            modal.innerHTML = Screens.viewRecurringModal(recurring, categories, accounts);
            this.bindViewRecurringHandlers(overlay, recurring);
        } catch (err) {
            modal.innerHTML = `<p class="text-center text-muted">Failed to load details</p>`;
        }

        // Close on overlay click
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });
    },

    bindViewRecurringHandlers(overlay, recurring) {
        // Close button
        document.getElementById('close-view-recurring').addEventListener('click', () => overlay.remove());

        // Delete button
        document.getElementById('delete-recurring-btn').addEventListener('click', async () => {
            if (confirm(`Delete "${recurring.name}"?`)) {
                try {
                    await API.deleteRecurring(recurring.id);
                    overlay.remove();
                    this.showToast('Recurring deleted!', 'success');
                    this.loadRecurring(document.getElementById('main-content'));
                } catch (err) {
                    this.showToast('Error: ' + err.message, 'error');
                }
            }
        });

        // Edit form submission
        document.getElementById('edit-recurring-form').addEventListener('submit', async (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            const submitBtn = e.target.querySelector('button[type="submit"]');

            const updates = {
                name: formData.get('name'),
                amount: Math.round(parseFloat(formData.get('amount')) * 100),
                category: formData.get('category') || null,
                account_id: formData.get('account_id') || null,
                frequency: formData.get('frequency'),
                day_of_month: parseInt(formData.get('day_of_month')) || 1,
                requires_verification: formData.get('requires_verification') === 'on',
                is_active: formData.get('is_active') === 'on',
            };

            try {
                submitBtn.disabled = true;
                submitBtn.textContent = 'Saving...';

                await API.updateRecurring(recurring.id, updates);
                overlay.remove();
                this.showToast('Recurring updated!', 'success');
                this.loadRecurring(document.getElementById('main-content'));
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Save Changes';
            }
        });
    },

    async showAddRecurringModal() {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'add-recurring-modal';

        const modal = document.createElement('div');
        modal.className = 'modal';

        try {
            const [categories, accounts] = await Promise.all([
                API.getCategoryList(),
                API.getAccounts()
            ]);
            modal.innerHTML = Screens.addRecurringModal(categories, accounts);
        } catch {
            modal.innerHTML = Screens.addRecurringModal([], []);
        }

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Close handlers
        document.getElementById('close-add-recurring').addEventListener('click', () => overlay.remove());
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });

        // Form submission
        document.getElementById('add-recurring-form').addEventListener('submit', async (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            const submitBtn = e.target.querySelector('button[type="submit"]');

            const recurring = {
                name: formData.get('name'),
                type: formData.get('type'),
                amount: Math.round(parseFloat(formData.get('amount')) * 100),
                category: formData.get('category') || null,
                account_id: formData.get('account_id') || null,
                frequency: formData.get('frequency'),
                day_of_month: parseInt(formData.get('day_of_month')) || 1,
                start_date: formData.get('start_date'),
                requires_verification: formData.get('requires_verification') === 'on',
                is_autopay: formData.get('is_autopay') === 'on',
            };

            try {
                submitBtn.disabled = true;
                submitBtn.textContent = 'Adding...';

                await API.createRecurring(recurring);
                overlay.remove();
                this.showToast('Recurring added!', 'success');
                this.loadRecurring(document.getElementById('main-content'));
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Add Recurring';
            }
        });
    },

    // -------------------------------------------------------------------------
    // More Menu
    // -------------------------------------------------------------------------

    async loadMore(container) {
        container.innerHTML = Screens.more();
        this.bindMoreHandlers();
    },

    bindMoreHandlers() {
        document.querySelectorAll('.menu-item').forEach(item => {
            item.addEventListener('click', () => {
                const screen = item.dataset.screen;
                this.showScreen(screen);
            });
        });
    },

    // -------------------------------------------------------------------------
    // Loans
    // -------------------------------------------------------------------------

    async loadLoans(container) {
        container.innerHTML = '<div class="loading">Loading...</div>';

        try {
            const loans = await API.getLoans();
            this.currentLoans = loans;
            container.innerHTML = Screens.loans(loans);
            this.bindLoansHandlers(loans);
        } catch (err) {
            container.innerHTML = `<div class="card"><p class="text-center text-muted">Failed to load loans</p></div>`;
        }
    },

    bindLoansHandlers(loans) {
        const addBtn = document.getElementById('add-loan-btn');
        if (addBtn) {
            addBtn.addEventListener('click', () => this.showAddLoanModal());
        }

        // Click on loan item to view/edit
        document.querySelectorAll('.loan-item').forEach(item => {
            item.addEventListener('click', () => {
                const loanId = item.dataset.loanId;
                if (loanId) {
                    this.showViewLoanModal(loanId);
                }
            });
        });
    },

    async showViewLoanModal(loanId) {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'view-loan-modal';

        const modal = document.createElement('div');
        modal.className = 'modal modal-large';
        modal.innerHTML = '<div class="loading">Loading...</div>';

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        try {
            const [loan, accounts] = await Promise.all([
                API.getLoan(loanId),
                API.getAccounts()
            ]);

            modal.innerHTML = Screens.viewLoanModal(loan, accounts);
            this.bindViewLoanHandlers(overlay, loan);
        } catch (err) {
            modal.innerHTML = `<p class="text-center text-muted">Failed to load details</p>`;
        }

        // Close on overlay click
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });
    },

    bindViewLoanHandlers(overlay, loan) {
        // Close button
        document.getElementById('close-view-loan').addEventListener('click', () => overlay.remove());

        // Close loan button
        document.getElementById('close-loan-btn').addEventListener('click', async () => {
            if (confirm(`Close "${loan.name}"? This will mark the loan as inactive.`)) {
                try {
                    await API.closeLoan(loan.id);
                    overlay.remove();
                    this.showToast('Loan closed!', 'success');
                    this.loadLoans(document.getElementById('main-content'));
                } catch (err) {
                    this.showToast('Error: ' + err.message, 'error');
                }
            }
        });

        // View amortization
        const amortBtn = document.getElementById('view-amortization-btn');
        if (amortBtn) {
            amortBtn.addEventListener('click', async () => {
                try {
                    const scheduleData = await API.getLoanSchedule(loan.id);
                    const schedHtml = scheduleData.schedule.map(s => `
                        <tr class="${s.paid ? 'row-paid' : ''}">
                            <td>${s.month}</td>
                            <td>${Screens.formatAmount(s.emi)}</td>
                            <td>${Screens.formatAmount(s.principal)}</td>
                            <td>${Screens.formatAmount(s.interest)}</td>
                            <td>${Screens.formatAmount(s.balance)}</td>
                            <td>${s.paid ? '✓' : ''}</td>
                        </tr>
                    `).join('');

                    const schedOverlay = document.createElement('div');
                    schedOverlay.className = 'modal-overlay';
                    const schedModal = document.createElement('div');
                    schedModal.className = 'modal modal-large';
                    schedModal.innerHTML = `
                        <div class="modal-header">
                            <h2 class="modal-title">Amortization Schedule</h2>
                            <button class="modal-close" id="close-amort-modal">✕</button>
                        </div>
                        <div style="overflow-x:auto;">
                            <table class="data-table">
                                <thead><tr>
                                    <th>Month</th><th>EMI</th><th>Principal</th><th>Interest</th><th>Balance</th><th>Paid</th>
                                </tr></thead>
                                <tbody>${schedHtml}</tbody>
                            </table>
                        </div>
                    `;
                    schedOverlay.appendChild(schedModal);
                    document.body.appendChild(schedOverlay);
                    document.getElementById('close-amort-modal').addEventListener('click', () => schedOverlay.remove());
                    schedOverlay.addEventListener('click', (e) => { if (e.target === schedOverlay) schedOverlay.remove(); });
                } catch (err) {
                    this.showToast('Error: ' + err.message, 'error');
                }
            });
        }

        // Manage EMI schedule
        const manageBtn = document.getElementById('manage-emi-schedule-btn');
        if (manageBtn) {
            manageBtn.addEventListener('click', async () => {
                try {
                    const emiData = await API.getLoanEmiSchedule(loan.id);
                    this.showEmiScheduleModal(overlay, loan, emiData.schedule);
                } catch (err) {
                    this.showToast('Error: ' + err.message, 'error');
                }
            });
        }

        // Revert to fixed EMI
        const revertBtn = document.getElementById('revert-fixed-emi-btn');
        if (revertBtn) {
            revertBtn.addEventListener('click', async () => {
                if (confirm('Revert to fixed EMI? The variable schedule will be deleted.')) {
                    try {
                        await API.deleteLoanEmiSchedule(loan.id);
                        overlay.remove();
                        this.showToast('Reverted to fixed EMI', 'success');
                        this.loadLoans(document.getElementById('main-content'));
                    } catch (err) {
                        this.showToast('Error: ' + err.message, 'error');
                    }
                }
            });
        }

        // Edit form submission
        document.getElementById('edit-loan-form').addEventListener('submit', async (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            const submitBtn = e.target.querySelector('button[type="submit"]');

            const updates = {
                name: formData.get('name'),
                emi_amount: Math.round(parseFloat(formData.get('emi_amount')) * 100),
                emi_day: parseInt(formData.get('emi_day')) || loan.emi_day,
                lender: formData.get('lender') || null,
                payment_account_id: formData.get('payment_account_id') || null,
            };

            try {
                submitBtn.disabled = true;
                submitBtn.textContent = 'Saving...';

                await API.updateLoan(loan.id, updates);
                overlay.remove();
                this.showToast('Loan updated!', 'success');
                this.loadLoans(document.getElementById('main-content'));
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Save Changes';
            }
        });
    },

    showEmiScheduleModal(parentOverlay, loan, schedule) {
        const schedOverlay = document.createElement('div');
        schedOverlay.className = 'modal-overlay';
        const schedModal = document.createElement('div');
        schedModal.className = 'modal';
        schedModal.innerHTML = Screens.emiScheduleModal(loan, schedule);
        schedOverlay.appendChild(schedModal);
        document.body.appendChild(schedOverlay);

        document.getElementById('close-emi-schedule').addEventListener('click', () => schedOverlay.remove());
        document.getElementById('cancel-emi-schedule').addEventListener('click', () => schedOverlay.remove());
        schedOverlay.addEventListener('click', (e) => { if (e.target === schedOverlay) schedOverlay.remove(); });

        // Add row button
        document.getElementById('add-emi-edit-row-btn').addEventListener('click', () => {
            const container = document.getElementById('emi-schedule-edit-rows');
            const row = document.createElement('div');
            row.className = 'form-row emi-schedule-row';
            row.innerHTML = `
                <div class="form-group" style="flex:1;">
                    <input type="number" class="form-input emi-month-input" placeholder="Month #" min="1" max="${loan.tenure_months}">
                </div>
                <div class="form-group" style="flex:1;">
                    <input type="number" class="form-input emi-amount-input" placeholder="EMI (₹)">
                </div>
            `;
            container.appendChild(row);
        });

        // Save button
        document.getElementById('save-emi-schedule').addEventListener('click', async () => {
            const entries = [];
            document.querySelectorAll('#emi-schedule-edit-rows .emi-schedule-row').forEach(row => {
                const month = parseInt(row.querySelector('.emi-month-input').value);
                const amount = parseFloat(row.querySelector('.emi-amount-input').value);
                if (month && amount) {
                    entries.push({ month_number: month, emi_amount: Math.round(amount * 100) });
                }
            });

            if (entries.length === 0) {
                this.showToast('Add at least one month entry', 'error');
                return;
            }

            try {
                await API.setLoanEmiSchedule(loan.id, entries);
                schedOverlay.remove();
                parentOverlay.remove();
                this.showToast('EMI schedule saved!', 'success');
                this.loadLoans(document.getElementById('main-content'));
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
            }
        });
    },

    async showAddLoanModal() {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'add-loan-modal';

        const modal = document.createElement('div');
        modal.className = 'modal';

        try {
            const accounts = await API.getAccounts();
            modal.innerHTML = Screens.addLoanModal(accounts);
        } catch {
            modal.innerHTML = Screens.addLoanModal([]);
        }

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Close handlers
        document.getElementById('close-add-loan').addEventListener('click', () => overlay.remove());
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });

        // Variable EMI toggle
        const variableToggle = document.getElementById('variable-emi-toggle');
        const variableSection = document.getElementById('variable-emi-section');
        if (variableToggle && variableSection) {
            variableToggle.addEventListener('change', () => {
                variableSection.style.display = variableToggle.checked ? 'block' : 'none';
            });
        }

        // Add EMI schedule row button
        const addRowBtn = document.getElementById('add-emi-row-btn');
        if (addRowBtn) {
            addRowBtn.addEventListener('click', () => {
                const container = document.getElementById('emi-schedule-rows');
                const row = document.createElement('div');
                row.className = 'form-row emi-schedule-row';
                row.innerHTML = `
                    <div class="form-group" style="flex:1;">
                        <input type="number" class="form-input emi-month-input" placeholder="Month #" min="1">
                    </div>
                    <div class="form-group" style="flex:1;">
                        <input type="number" class="form-input emi-amount-input" placeholder="EMI (₹)">
                    </div>
                `;
                container.appendChild(row);
            });
        }

        // Form submission
        document.getElementById('add-loan-form').addEventListener('submit', async (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            const submitBtn = e.target.querySelector('button[type="submit"]');

            const loan = {
                name: formData.get('name'),
                type: formData.get('type'),
                principal: Math.round(parseFloat(formData.get('principal')) * 100),
                interest_rate: parseFloat(formData.get('interest_rate')),
                tenure_months: parseInt(formData.get('tenure_months')),
                emi_amount: Math.round(parseFloat(formData.get('emi_amount')) * 100),
                emi_day: parseInt(formData.get('emi_day')) || 5,
                start_date: formData.get('start_date'),
                lender: formData.get('lender') || null,
                payment_account_id: formData.get('payment_account_id') || null,
            };

            // Collect variable EMI schedule if enabled
            if (variableToggle && variableToggle.checked) {
                const schedule = [];
                document.querySelectorAll('#emi-schedule-rows .emi-schedule-row').forEach(row => {
                    const month = parseInt(row.querySelector('.emi-month-input').value);
                    const amount = parseFloat(row.querySelector('.emi-amount-input').value);
                    if (month && amount) {
                        schedule.push({ month_number: month, emi_amount: Math.round(amount * 100) });
                    }
                });
                if (schedule.length > 0) {
                    loan.emi_schedule = schedule;
                }
            }

            try {
                submitBtn.disabled = true;
                submitBtn.textContent = 'Adding...';

                await API.createLoan(loan);
                overlay.remove();
                this.showToast('Loan added!', 'success');
                this.loadLoans(document.getElementById('main-content'));
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Add Loan';
            }
        });
    },

    // -------------------------------------------------------------------------
    // Credit Cards
    // -------------------------------------------------------------------------

    async loadCreditCards(container) {
        container.innerHTML = '<div class="loading">Loading...</div>';

        try {
            const cards = await API.getCreditCards();
            // Get details for each card
            const cardsWithDetails = await Promise.all(
                cards.map(async card => {
                    try {
                        const details = await API.getCreditCardDetails(card.id);
                        return { ...card, ...details };
                    } catch {
                        return card;
                    }
                })
            );
            container.innerHTML = Screens.creditCards(cardsWithDetails);
            this.bindCreditCardsHandlers(cardsWithDetails);
        } catch (err) {
            container.innerHTML = `<div class="card"><p class="text-center text-muted">Failed to load credit cards</p></div>`;
        }
    },

    bindCreditCardsHandlers(cards) {
        document.querySelectorAll('.pay-card-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                const item = btn.closest('.credit-card-item');
                const cardId = item.dataset.cardId;
                const card = cards.find(c => c.id === cardId);
                if (card) {
                    this.showPayCardModal(card);
                }
            });
        });
    },

    async showPayCardModal(card) {
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        overlay.id = 'pay-card-modal';

        const modal = document.createElement('div');
        modal.className = 'modal modal-small';

        try {
            const accounts = await API.getAccounts();
            modal.innerHTML = Screens.payCardModal(card, accounts);
        } catch {
            modal.innerHTML = Screens.payCardModal(card, []);
        }

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Close handlers
        document.getElementById('close-pay-card').addEventListener('click', () => overlay.remove());
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.remove();
        });

        // Form submission
        document.getElementById('pay-card-form').addEventListener('submit', async (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            const submitBtn = e.target.querySelector('button[type="submit"]');

            const amount = Math.round(parseFloat(formData.get('amount')) * 100);
            const fromAccountId = formData.get('from_account_id');

            if (!fromAccountId) {
                this.showToast('Please select an account', 'error');
                return;
            }

            try {
                submitBtn.disabled = true;
                submitBtn.textContent = 'Processing...';

                // Create a transfer event (pay credit card)
                await API.createTransfer(fromAccountId, card.id, amount, `Credit card payment - ${card.name}`);

                overlay.remove();
                this.showToast('Payment successful!', 'success');
                this.loadCreditCards(document.getElementById('main-content'));
            } catch (err) {
                this.showToast('Error: ' + err.message, 'error');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Pay Now';
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

