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
        modal.className = 'modal';
        modal.innerHTML = Screens.settings(null);

        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Load settings
        try {
            const settings = await API.getSettings();
            modal.innerHTML = Screens.settings(settings);
            this.bindSettingsHandlers(overlay);
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

    bindSettingsHandlers(overlay) {
        // Close button
        const closeBtn = document.getElementById('close-settings');
        if (closeBtn) {
            closeBtn.addEventListener('click', () => this.closeSettings());
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
    },

    async handleSaveSettings(form) {
        const formData = new FormData(form);
        const submitBtn = form.querySelector('button[type="submit"]');

        const budgetRupees = parseFloat(formData.get('base_budget'));
        const budgetPaise = Math.round(budgetRupees * 100);

        try {
            submitBtn.disabled = true;
            submitBtn.textContent = 'Saving...';

            await API.updateSettings({ base_budget: budgetPaise });

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

