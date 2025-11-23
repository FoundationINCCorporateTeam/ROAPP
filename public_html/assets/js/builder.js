/**
 * Application Center Builder - Main JavaScript
 * 
 * Handles drag-and-drop builder UI, live preview, and all builder interactions
 */

class AppBuilder {
    constructor() {
        this.currentApp = null;
        this.questions = [];
        this.isDragging = false;
        this.draggedElement = null;
        
        this.init();
    }
    
    init() {
        this.setupThemeToggle();
        this.setupEventListeners();
        this.loadAppList();
        this.renderBuilder();
    }
    
    /**
     * Setup theme toggle
     */
    setupThemeToggle() {
        const savedTheme = localStorage.getItem('theme') || 'light';
        document.documentElement.setAttribute('data-theme', savedTheme);
        
        const toggle = document.getElementById('theme-toggle');
        if (toggle) {
            toggle.addEventListener('click', () => {
                const currentTheme = document.documentElement.getAttribute('data-theme');
                const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
                
                document.documentElement.setAttribute('data-theme', newTheme);
                localStorage.setItem('theme', newTheme);
            });
        }
    }
    
    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // New app button
        const newAppBtn = document.getElementById('new-app-btn');
        if (newAppBtn) {
            newAppBtn.addEventListener('click', () => this.createNewApp());
        }
        
        // Save app button
        const saveAppBtn = document.getElementById('save-app-btn');
        if (saveAppBtn) {
            saveAppBtn.addEventListener('click', () => this.saveApp());
        }
        
        // Add question button
        const addQuestionBtn = document.getElementById('add-question-btn');
        if (addQuestionBtn) {
            addQuestionBtn.addEventListener('click', () => this.showAddQuestionModal());
        }
        
        // Form inputs for live preview
        this.setupLivePreview();
    }
    
    /**
     * Setup live preview updates
     */
    setupLivePreview() {
        const inputs = ['app-name', 'app-description', 'primary-color', 'secondary-color'];
        
        inputs.forEach(id => {
            const element = document.getElementById(id);
            if (element) {
                element.addEventListener('input', () => this.updatePreview());
            }
        });
    }
    
    /**
     * Create new application
     */
    createNewApp() {
        this.currentApp = {
            id: null,
            app: {
                name: '',
                description: '',
                group_id: '',
                target_role: '',
                pass_score: 70
            },
            style: {
                primary_color: '#ff4b6e',
                secondary_color: '#1f2933',
                background: 'gradient:linear,#1f2933,#111827',
                font: 'Inter',
                button_shape: 'pill'
            },
            questions: []
        };
        
        this.questions = [];
        this.renderBuilder();
        this.updatePreview();
    }
    
    /**
     * Load application list
     */
    async loadAppList() {
        try {
            const response = await fetch('index.php?action=listApps');
            const data = await response.json();
            
            if (data.success) {
                this.renderAppList(data.apps);
            }
        } catch (error) {
            console.error('Failed to load app list:', error);
        }
    }
    
    /**
     * Render app list in sidebar
     */
    renderAppList(apps) {
        const list = document.getElementById('app-list');
        if (!list) return;
        
        list.innerHTML = '';
        
        apps.forEach(app => {
            const item = document.createElement('li');
            item.className = 'sidebar-item';
            item.innerHTML = `
                <span>📋</span>
                <span>${this.escapeHtml(app.name)}</span>
            `;
            
            item.addEventListener('click', () => this.loadApp(app.id));
            list.appendChild(item);
        });
    }
    
    /**
     * Load an application
     */
    async loadApp(id) {
        try {
            const response = await fetch(`index.php?action=loadApp&id=${encodeURIComponent(id)}`);
            const data = await response.json();
            
            if (data.success) {
                this.currentApp = data.data;
                this.currentApp.id = id;
                this.questions = data.data.questions || [];
                this.renderBuilder();
                this.updatePreview();
                
                this.showToast('Application loaded successfully', 'success');
            } else {
                this.showToast(data.error || 'Failed to load application', 'error');
            }
        } catch (error) {
            console.error('Failed to load app:', error);
            this.showToast('Failed to load application', 'error');
        }
    }
    
    /**
     * Save application
     */
    async saveApp() {
        if (!this.currentApp) {
            this.showToast('No application to save', 'error');
            return;
        }
        
        // Collect form data
        this.currentApp.app.name = document.getElementById('app-name')?.value || '';
        this.currentApp.app.description = document.getElementById('app-description')?.value || '';
        this.currentApp.app.group_id = parseInt(document.getElementById('group-id')?.value || '0');
        this.currentApp.app.target_role = document.getElementById('target-role')?.value || '';
        this.currentApp.app.pass_score = parseInt(document.getElementById('pass-score')?.value || '70');
        
        this.currentApp.style.primary_color = document.getElementById('primary-color')?.value || '#ff4b6e';
        this.currentApp.style.secondary_color = document.getElementById('secondary-color')?.value || '#1f2933';
        
        this.currentApp.questions = this.questions;
        
        // Validate
        if (!this.currentApp.app.name) {
            this.showToast('Application name is required', 'error');
            return;
        }
        
        try {
            const response = await fetch('index.php?action=saveApp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(this.currentApp)
            });
            
            const data = await response.json();
            
            if (data.success) {
                this.currentApp.id = data.id;
                this.showToast('Application saved successfully', 'success');
                this.loadAppList(); // Refresh app list
            } else {
                this.showToast(data.error || 'Failed to save application', 'error');
            }
        } catch (error) {
            console.error('Failed to save app:', error);
            this.showToast('Failed to save application', 'error');
        }
    }
    
    /**
     * Show add question modal
     */
    showAddQuestionModal() {
        const modal = document.createElement('div');
        modal.className = 'modal-overlay';
        modal.innerHTML = `
            <div class="modal">
                <div class="modal-header">
                    <h3 class="modal-title">Add Question</h3>
                    <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">×</button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label class="form-label">Question Type</label>
                        <select id="new-question-type" class="form-select">
                            <option value="multiple_choice">Multiple Choice</option>
                            <option value="short_answer">Short Answer</option>
                            <option value="checkboxes">Checkboxes</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Question Text</label>
                        <textarea id="new-question-text" class="form-textarea" placeholder="Enter your question..."></textarea>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Points</label>
                        <input type="number" id="new-question-points" class="form-input" value="10" min="1">
                    </div>
                    <button class="btn btn-primary" onclick="appBuilder.addQuestion()">Add Question</button>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
    }
    
    /**
     * Add question
     */
    addQuestion() {
        const type = document.getElementById('new-question-type')?.value;
        const text = document.getElementById('new-question-text')?.value;
        const points = parseInt(document.getElementById('new-question-points')?.value || '10');
        
        if (!text) {
            this.showToast('Question text is required', 'error');
            return;
        }
        
        const question = {
            id: 'q' + Date.now(),
            type: type,
            text: text,
            points: points
        };
        
        // Add type-specific properties
        if (type === 'multiple_choice') {
            question.options = [
                { id: 'a', text: 'Option A', correct: true },
                { id: 'b', text: 'Option B', correct: false }
            ];
        } else if (type === 'checkboxes') {
            question.options = [
                { id: 'a', text: 'Option A', correct: true },
                { id: 'b', text: 'Option B', correct: false }
            ];
            question.max_score = points;
            question.scoring = {
                points_per_correct: 5,
                penalty_per_incorrect: 1
            };
        } else if (type === 'short_answer') {
            question.max_length = 300;
            question.grading_criteria = 'Grade based on relevance and quality';
        }
        
        this.questions.push(question);
        this.renderQuestions();
        this.updatePreview();
        
        // Close modal
        document.querySelector('.modal-overlay')?.remove();
    }
    
    /**
     * Render builder interface
     */
    renderBuilder() {
        const builderArea = document.getElementById('builder-area');
        if (!builderArea) return;
        
        builderArea.innerHTML = `
            <div class="glass-card">
                <h2>Application Settings</h2>
                
                <div class="form-group">
                    <label class="form-label">Application Name *</label>
                    <input type="text" id="app-name" class="form-input" 
                           value="${this.escapeHtml(this.currentApp?.app?.name || '')}"
                           placeholder="e.g., Staff Application">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea id="app-description" class="form-textarea"
                              placeholder="Describe your application...">${this.escapeHtml(this.currentApp?.app?.description || '')}</textarea>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Group ID *</label>
                    <input type="number" id="group-id" class="form-input"
                           value="${this.currentApp?.app?.group_id || ''}"
                           placeholder="e.g., 123456">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Target Role *</label>
                    <input type="text" id="target-role" class="form-input"
                           value="${this.escapeHtml(this.currentApp?.app?.target_role || '')}"
                           placeholder="e.g., groups/7/roles/99513316">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Pass Score (%)</label>
                    <input type="number" id="pass-score" class="form-input"
                           value="${this.currentApp?.app?.pass_score || 70}"
                           min="0" max="100">
                </div>
            </div>
            
            <div class="glass-card mt-lg">
                <h2>Styling</h2>
                
                <div class="form-group">
                    <label class="form-label">Primary Color</label>
                    <input type="color" id="primary-color" class="form-input"
                           value="${this.currentApp?.style?.primary_color || '#ff4b6e'}">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Secondary Color</label>
                    <input type="color" id="secondary-color" class="form-input"
                           value="${this.currentApp?.style?.secondary_color || '#1f2933'}">
                </div>
            </div>
            
            <div class="glass-card mt-lg">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                    <h2 class="mb-0">Questions</h2>
                    <button id="add-question-btn" class="btn btn-primary">+ Add Question</button>
                </div>
                
                <div id="questions-container"></div>
            </div>
        `;
        
        this.setupEventListeners();
        this.renderQuestions();
    }
    
    /**
     * Render questions
     */
    renderQuestions() {
        const container = document.getElementById('questions-container');
        if (!container) return;
        
        if (this.questions.length === 0) {
            container.innerHTML = '<p class="text-muted text-center">No questions yet. Click "Add Question" to get started.</p>';
            return;
        }
        
        container.innerHTML = '<div class="question-list" id="question-list"></div>';
        const list = document.getElementById('question-list');
        
        this.questions.forEach((question, index) => {
            const card = this.createQuestionCard(question, index);
            list.appendChild(card);
        });
        
        this.setupDragAndDrop();
    }
    
    /**
     * Create question card element
     */
    createQuestionCard(question, index) {
        const card = document.createElement('div');
        card.className = 'question-card';
        card.draggable = true;
        card.dataset.index = index;
        
        card.innerHTML = `
            <div class="question-header">
                <span class="question-type-badge">${question.type.replace('_', ' ')}</span>
                <div class="question-actions">
                    <button class="icon-btn" onclick="appBuilder.editQuestion(${index})">✏️</button>
                    <button class="icon-btn delete" onclick="appBuilder.deleteQuestion(${index})">🗑️</button>
                </div>
            </div>
            <h4>${this.escapeHtml(question.text)}</h4>
            <p class="text-muted">Points: ${question.points}</p>
        `;
        
        return card;
    }
    
    /**
     * Setup drag and drop
     */
    setupDragAndDrop() {
        const cards = document.querySelectorAll('.question-card');
        
        cards.forEach(card => {
            card.addEventListener('dragstart', (e) => {
                card.classList.add('dragging');
                this.draggedElement = card;
            });
            
            card.addEventListener('dragend', (e) => {
                card.classList.remove('dragging');
                this.draggedElement = null;
            });
            
            card.addEventListener('dragover', (e) => {
                e.preventDefault();
                const afterElement = this.getDragAfterElement(e.clientY);
                const list = document.getElementById('question-list');
                
                if (afterElement == null) {
                    list.appendChild(this.draggedElement);
                } else {
                    list.insertBefore(this.draggedElement, afterElement);
                }
            });
            
            card.addEventListener('drop', (e) => {
                e.preventDefault();
                this.reorderQuestions();
            });
        });
    }
    
    /**
     * Get element after dragged position
     */
    getDragAfterElement(y) {
        const cards = [...document.querySelectorAll('.question-card:not(.dragging)')];
        
        return cards.reduce((closest, child) => {
            const box = child.getBoundingClientRect();
            const offset = y - box.top - box.height / 2;
            
            if (offset < 0 && offset > closest.offset) {
                return { offset: offset, element: child };
            } else {
                return closest;
            }
        }, { offset: Number.NEGATIVE_INFINITY }).element;
    }
    
    /**
     * Reorder questions after drag and drop
     */
    reorderQuestions() {
        const cards = document.querySelectorAll('.question-card');
        const newOrder = [];
        
        cards.forEach(card => {
            const index = parseInt(card.dataset.index);
            newOrder.push(this.questions[index]);
        });
        
        this.questions = newOrder;
        this.renderQuestions();
        this.updatePreview();
    }
    
    /**
     * Edit question
     */
    editQuestion(index) {
        // For now, just show an alert - can be expanded
        this.showToast('Question editing coming soon!', 'info');
    }
    
    /**
     * Delete question
     */
    deleteQuestion(index) {
        if (confirm('Are you sure you want to delete this question?')) {
            this.questions.splice(index, 1);
            this.renderQuestions();
            this.updatePreview();
        }
    }
    
    /**
     * Update live preview
     */
    updatePreview() {
        const preview = document.getElementById('preview-content');
        if (!preview) return;
        
        const appName = document.getElementById('app-name')?.value || 'Your Application';
        const appDesc = document.getElementById('app-description')?.value || 'Application description';
        
        let questionsHtml = '';
        this.questions.forEach((q, i) => {
            questionsHtml += `
                <div style="margin-bottom: 1rem; padding: 1rem; background: var(--bg-secondary); border-radius: var(--radius-md);">
                    <strong>Q${i + 1}. ${this.escapeHtml(q.text)}</strong>
                    <p class="text-muted" style="font-size: 0.875rem;">Type: ${q.type.replace('_', ' ')}</p>
                </div>
            `;
        });
        
        preview.innerHTML = `
            <h3 style="margin-bottom: 0.5rem;">${this.escapeHtml(appName)}</h3>
            <p class="text-muted" style="margin-bottom: 1.5rem;">${this.escapeHtml(appDesc)}</p>
            ${questionsHtml || '<p class="text-muted">No questions added yet</p>'}
        `;
    }
    
    /**
     * Show toast notification
     */
    showToast(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.textContent = message;
        
        document.body.appendChild(toast);
        
        setTimeout(() => {
            toast.style.animation = 'toastSlideIn 0.3s ease reverse';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }
    
    /**
     * Escape HTML
     */
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize builder when DOM is ready
let appBuilder;
document.addEventListener('DOMContentLoaded', () => {
    appBuilder = new AppBuilder();
});
