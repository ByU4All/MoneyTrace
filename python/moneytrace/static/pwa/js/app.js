// MoneyTrace PWA - Main Application
// v0.1.0 - App initialization and navigation

const App = {
    currentScreen: 'dashboard',

    /**
     * Convert major units (rupees) to minor units (paise)
     * @param {number} majorUnits - Amount in rupees
     * @returns {number} - Amount in paise
     */
    toMinorUnits(majorUnits) {
        return Math.round(majorUnits * 100);
    },

    /**
     * Convert minor units (paise) to major units (rupees)
     * @param {number} minorUnits - Amount in paise
     * @returns {number} - Amount in rupees
     */
    toMajorUnits(minorUnits) {
        return minorUnits / 100;
    },

    /**
     * Initialize the application
     */
    init() {
        this.bindNavigation();
        this.showScreen('dashboard');
    },

    /**
     * Bind navigation button clicks
     */
    bindNavigation() {
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const screen = btn.dataset.screen;
                this.showScreen(screen);
            });
        });
    },

    /**
     * Update navigation active state
     */
    updateNavActive(screenName) {
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.screen === screenName);
        });
    },

    /**
     * Show a screen
     */
    async showScreen(screenName) {
        this.currentScreen = screenName;
        this.updateNavActive(screenName);

        const main = document.querySelector('.app-main');

        switch (screenName) {
            case 'dashboard':
                await this.loadDashboard(main);
                break;
            case 'add-event':
                this.loadAddEvent(main);
                break;
            case 'friends':
                await this.loadFriends(main);
                break;
            case 'categories':
                await this.loadCategories(main);
                break;
        }
    },

    /**
     * Load dashboard screen
     */
    async loadDashboard(container) {
        container.innerHTML = Screens.dashboard(null);

        try {
            const now = new Date();
            const data = await API.getSummary(now.getMonth() + 1, now.getFullYear());
            container.innerHTML = Screens.dashboard(data);
        } catch (err) {
            container.innerHTML = `
                <div class="card">
                    <p class="text-center text-muted">Failed to load dashboard</p>
                    <p class="text-center text-muted">${err.message}</p>
                </div>
            `;
        }
    },

    /**
     * Load add event screen
     */
    async loadAddEvent(container) {
        // Show loading state first
        container.innerHTML = '<div class="loading">Loading...</div>';

        try {
            // Fetch friends list for the dropdown
            const friends = await API.getFriends();
            container.innerHTML = Screens.addEvent(friends);

            // Bind event handlers
            this.bindEventFormHandlers();
        } catch (err) {
            // If fetching friends fails, still show the form
            container.innerHTML = Screens.addEvent([]);
            this.bindEventFormHandlers();
        }
    },

    /**
     * Bind event form handlers (type change, amount display, submit)
     */
    bindEventFormHandlers() {
        const form = document.querySelector('#event-form');
        const typeSelect = document.querySelector('#event-type');
        const amountInput = document.querySelector('#event-amount');
        const amountDisplay = document.querySelector('#amount-display');
        const friendGroup = document.querySelector('#friend-group');
        const friendSelect = document.querySelector('#friend-select');

        // Handle event type changes to show/hide friend dropdown
        if (typeSelect && friendGroup) {
            typeSelect.addEventListener('change', (e) => {
                const needsFriend = [
                    'liability_created',
                    'receivable_created',
                    'payback_paid',
                    'payback_received'
                ].includes(e.target.value);

                friendGroup.style.display = needsFriend ? 'block' : 'none';

                // Make friend required for these types
                if (friendSelect) {
                    if (needsFriend) {
                        friendSelect.setAttribute('required', 'required');
                    } else {
                        friendSelect.removeAttribute('required');
                    }
                }
            });
        }

        // Handle amount input to show conversion
        if (amountInput && amountDisplay) {
            amountInput.addEventListener('input', (e) => {
                const rupees = parseFloat(e.target.value) || 0;
                const paise = this.toMinorUnits(rupees);
                amountDisplay.textContent = `= ${paise.toLocaleString()} paise`;
            });
        }

        // Handle form submission
        if (form) {
            form.addEventListener('submit', async (e) => {
                e.preventDefault();
                await this.handleEventSubmit(form);
            });
        }
    },

    /**
     * Handle event form submission
     */
    async handleEventSubmit(form) {
        const formData = new FormData(form);

        // Convert amount from rupees to paise using utility function
        const amountRupees = parseFloat(formData.get('amount'));
        const amountPaise = this.toMinorUnits(amountRupees);

        // Build event object
        const event = {
            event_type: formData.get('type'),
            amount: amountPaise,
            category: formData.get('category') || 'uncategorized',
            note: formData.get('description') || null,
            friend_id: formData.get('friend_id') || null,
        };

        // Remove friend_id if empty
        if (!event.friend_id) {
            delete event.friend_id;
        }

        try {
            const submitBtn = form.querySelector('button[type="submit"]');
            const originalText = submitBtn.textContent;
            submitBtn.disabled = true;
            submitBtn.textContent = 'Adding...';

            await API.createEvent(event);

            // Show success message
            this.showNotification('Event added successfully!', 'success');
            form.reset();

            // Navigate to dashboard after a short delay
            setTimeout(() => {
                this.showScreen('dashboard');
            }, 500);
        } catch (err) {
            this.showNotification(`Error: ${err.message}`, 'error');
        } finally {
            const submitBtn = form.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.textContent = 'Add Event';
            }
        }
    },

    /**
     * Show a notification message
     */
    showNotification(message, type = 'info') {
        // Simple alert for now - can be enhanced with a better UI later
        alert(message);
    },

    /**
     * Load friends screen
     */
    async loadFriends(container) {
        container.innerHTML = Screens.friends(null);

        try {
            const data = await API.getFriends();
            container.innerHTML = Screens.friends(data);
        } catch (err) {
            container.innerHTML = `
                <div class="card">
                    <p class="text-center text-muted">Failed to load friends</p>
                    <p class="text-center text-muted">${err.message}</p>
                </div>
            `;
        }
    },

    /**
     * Load categories screen
     */
    async loadCategories(container) {
        container.innerHTML = Screens.categories(null);

        try {
            const now = new Date();
            const data = await API.getCategories(now.getMonth() + 1, now.getFullYear());
            container.innerHTML = Screens.categories(data);
        } catch (err) {
            container.innerHTML = `
                <div class="card">
                    <p class="text-center text-muted">Failed to load categories</p>
                    <p class="text-center text-muted">${err.message}</p>
                </div>
            `;
        }
    }
};

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    App.init();
});

// Export for debugging
window.App = App;

