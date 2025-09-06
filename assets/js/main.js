// Form switching functionality for contact page
function showForm(formType) {
    // Hide all forms
    const forms = document.querySelectorAll('.contact-form');
    forms.forEach(form => form.style.display = 'none');
    
    // Show selected form
    document.getElementById(formType + '-form').style.display = 'block';
    
    // Update path cards
    const cards = document.querySelectorAll('.path-card');
    cards.forEach(card => card.classList.remove('active'));
    document.querySelector(`[data-form="${formType}"]`).classList.add('active');
    
    // Scroll to form
    document.querySelector('.roi-calculator').scrollIntoView({ behavior: 'smooth' });
}

// Show plan information in the signup form
function showPlanInfo(plan) {
    const planDetails = {
        'professional': {
            name: 'Professional',
            price: '$12,000/year',
            features: '1-49 employees, unlimited transactions, full ERP suite',
            color: 'var(--primary-gradient-start)'
        },
        'business': {
            name: 'Business',
            price: '$25,000/year',
            features: '50-100 employees, multi-location, API access',
            color: 'var(--primary-gradient-start)'
        },
        'starter': {
            name: 'Starter',
            price: 'Free (1,000 transactions/mo)',
            features: 'Perfect for getting started with Vilara',
            color: 'var(--success)'
        }
    };
    
    if (planDetails[plan]) {
        const details = planDetails[plan];
        
        // Add plan indicator to the form
        const formTitle = document.querySelector('#free-form h2');
        if (formTitle) {
            // Create plan badge if it doesn't exist
            let planBadge = document.getElementById('selected-plan-badge');
            if (!planBadge) {
                planBadge = document.createElement('div');
                planBadge.id = 'selected-plan-badge';
                planBadge.style.cssText = `
                    background: ${details.color};
                    color: white;
                    padding: 0.5rem 1rem;
                    border-radius: 2rem;
                    margin: 1rem auto;
                    display: inline-block;
                    font-weight: 600;
                `;
                formTitle.parentNode.insertBefore(planBadge, formTitle.nextSibling);
            }
            planBadge.innerHTML = `Selected Plan: ${details.name} - ${details.price}`;
            
            // Update subtitle based on plan
            const subtitle = document.getElementById('free-form-subtitle');
            if (subtitle) {
                if (plan === 'professional' || plan === 'business') {
                    subtitle.innerHTML = `Starting with the ${details.name} plan. Complete your signup below and we'll help you get started!`;
                }
            }
            
            // Update form title for paid plans
            if (formTitle && (plan === 'professional' || plan === 'business')) {
                formTitle.innerHTML = `Start Your ${details.name} Plan`;
            }
            
            // Update button text and copy below for paid plans
            const submitBtn = document.getElementById('free-submit-btn');
            const buttonCopy = submitBtn?.parentElement?.querySelector('p');
            
            if (submitBtn) {
                if (plan === 'professional' || plan === 'business') {
                    submitBtn.textContent = `Start ${details.name} Plan`;
                    if (buttonCopy) {
                        buttonCopy.innerHTML = `${details.price} • 14-day free trial • Cancel anytime`;
                    }
                } else if (plan === 'starter') {
                    submitBtn.textContent = 'Get Free Access';
                    if (buttonCopy) {
                        buttonCopy.innerHTML = 'No credit card required • Instant setup • Free forever';
                    }
                }
            }
            
            // Add hidden input for plan
            let planInput = document.getElementById('selected-plan-input');
            if (!planInput) {
                planInput = document.createElement('input');
                planInput.type = 'hidden';
                planInput.id = 'selected-plan-input';
                planInput.name = 'selected_plan';
                document.getElementById('free-signup-form').appendChild(planInput);
            }
            planInput.value = plan;
        }
    }
}

// Handle free signup form submission
function initializeSignupForm() {
    const signupForm = document.getElementById('free-signup-form');
    if (!signupForm) return; // Only run on contact page
    
    // Check for plan parameter in URL
    const urlParams = new URLSearchParams(window.location.search);
    const selectedPlan = urlParams.get('plan');
    
    // If plan is specified, show plan information
    if (selectedPlan) {
        showPlanInfo(selectedPlan);
    }
    
    signupForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const submitBtn = document.getElementById('free-submit-btn');
        const originalText = submitBtn.textContent;
        
        // Basic validation
        const password = document.getElementById('free-password').value;
        const confirmPassword = document.getElementById('free-confirm-password').value;
        
        if (password !== confirmPassword) {
            alert('Passwords do not match. Please try again.');
            return;
        }
        
        if (password.length < 8) {
            alert('Password must be at least 8 characters long.');
            return;
        }
        
        // Update button state
        submitBtn.textContent = 'Creating Account...';
        submitBtn.disabled = true;
        
        try {
            // Parse the full name into first and last
            const fullName = document.getElementById('free-name').value.trim();
            const nameParts = fullName.split(' ');
            const firstName = nameParts[0] || '';
            const lastName = nameParts.slice(1).join(' ') || nameParts[0] || '';
            
            // Map employee count to company size format expected by API
            const employeeCount = document.getElementById('free-employees').value;
            let companySize = '1-4'; // Default for free tier
            if (employeeCount === '5') {
                companySize = '1-4'; // Still counts as small
            } else if (employeeCount <= 4) {
                companySize = '1-4';
            }
            
            // Collect form data as JSON
            const signupData = {
                email: document.getElementById('free-email').value,
                firstName: firstName,
                lastName: lastName,
                companyName: document.getElementById('free-company').value,
                companySize: companySize,
                migrationContext: document.getElementById('free-current-system').value || 'none',
                // Additional fields the form collects but API doesn't require
                industry: document.getElementById('free-industry').value,
                goals: document.getElementById('free-goals').value
            };
            
            // Submit to our API with JSON
            const response = await fetch('/api/universal-signup.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(signupData)
            });
            
            const result = await response.json();
            
            if (result.success) {
                // Store activation data for the activation page
                localStorage.setItem('vilaraActivation', JSON.stringify({
                    onboarding_token: result.onboarding_token,
                    user_data: result.user_data,
                    ui_activation_methods: result.ui_activation_methods,
                    signup_source: 'website_free'
                }));
                
                // Show success message
                document.getElementById('free-form').innerHTML = `
                    <div style="text-align: center; padding: 2rem;">
                        <div style="background: var(--success); color: white; width: 80px; height: 80px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 2rem; font-size: 2rem;">🎉</div>
                        <h2 style="color: var(--success); margin-bottom: 1rem;">Account Created Successfully!</h2>
                        <p style="margin-bottom: 2rem; color: var(--text-light);">Redirecting you to activate your Vilara workspace...</p>
                        <div class="loading-spinner" style="margin: 0 auto; width: 40px; height: 40px; border: 4px solid #f3f3f3; border-top: 4px solid var(--success); border-radius: 50%; animation: spin 1s linear infinite;"></div>
                    </div>
                `;
                
                // Redirect to activation page after a brief delay
                setTimeout(() => {
                    window.location.href = '/activate.html';
                }, 2000);
                
            } else {
                // Show error message
                alert(result.message || 'An error occurred during signup. Please try again.');
                submitBtn.textContent = originalText;
                submitBtn.disabled = false;
            }
            
        } catch (error) {
            console.error('Signup error:', error);
            alert('A network error occurred. Please check your connection and try again.');
            submitBtn.textContent = originalText;
            submitBtn.disabled = false;
        }
    });
}

// Mobile menu toggle
function toggleMobileMenu() {
    const navMenu = document.querySelector('.nav-menu');
    const mobileToggle = document.querySelector('.mobile-menu-toggle');
    
    navMenu.classList.toggle('active');
    mobileToggle.classList.toggle('active');
    
    // Close menu when clicking outside
    if (navMenu.classList.contains('active')) {
        document.addEventListener('click', closeMobileMenuOnOutsideClick);
    } else {
        document.removeEventListener('click', closeMobileMenuOnOutsideClick);
    }
}

function closeMobileMenuOnOutsideClick(event) {
    const navMenu = document.querySelector('.nav-menu');
    const mobileToggle = document.querySelector('.mobile-menu-toggle');
    
    if (!navMenu.contains(event.target) && !mobileToggle.contains(event.target)) {
        navMenu.classList.remove('active');
        mobileToggle.classList.remove('active');
        document.removeEventListener('click', closeMobileMenuOnOutsideClick);
    }
}

// Currency formatting functions
function formatCurrency(value) {
    // Remove any non-digit characters except decimal points
    const numericValue = value.toString().replace(/[^\d.]/g, '');
    const number = parseFloat(numericValue) || 0;
    return number.toLocaleString('en-US');
}

function parseCurrency(value) {
    // Remove commas and dollar signs, parse as float
    return parseFloat(value.toString().replace(/[,$]/g, '')) || 0;
}

// ROI Calculator
function calculateROI() {
    const employees = parseInt(document.getElementById('employees').value) || 0;
    const dailyTasks = parseInt(document.getElementById('daily-tasks').value) || 0;
    const currentCost = parseCurrency(document.getElementById('current-cost').value) || 0;
    
    // Calculate time savings (95% reduction: 6 minutes to 17 seconds)
    const minutesPerTaskCurrent = 6;
    const minutesPerTaskVilara = 0.28; // 17 seconds
    const workDaysPerYear = 250;
    
    const totalTasksPerYear = employees * dailyTasks * workDaysPerYear;
    const currentTimeHours = (totalTasksPerYear * minutesPerTaskCurrent) / 60;
    const vilaraTimeHours = (totalTasksPerYear * minutesPerTaskVilara) / 60;
    const timeSavedHours = currentTimeHours - vilaraTimeHours;
    
    // Calculate cost savings
    const avgHourlyRate = 35; // Average employee hourly rate
    const laborSavings = timeSavedHours * avgHourlyRate;
    
    // Vilara costs (based on company size)
    let vilaraCost = 0;
    if (employees <= 25) {
        vilaraCost = 0; // Free tier
    } else if (employees <= 50) {
        vilaraCost = 10000; // Professional
    } else if (employees <= 100) {
        vilaraCost = 22500; // Business
    } else if (employees <= 500) {
        vilaraCost = 65000; // Enterprise
    } else {
        vilaraCost = 100000; // Enterprise Plus
    }
    
    const licenseSavings = currentCost - vilaraCost;
    const totalSavings = laborSavings + licenseSavings;
    const roi = ((totalSavings / (vilaraCost || 1)) * 100).toFixed(0);
    const paybackMonths = vilaraCost > 0 ? ((vilaraCost / totalSavings) * 12).toFixed(1) : 0;
    
    // Update results
    document.getElementById('time-saved').textContent = Math.round(timeSavedHours).toLocaleString() + ' hours/year';
    document.getElementById('cost-savings').textContent = '$' + Math.round(totalSavings).toLocaleString();
    document.getElementById('roi-percentage').textContent = roi + '%';
    document.getElementById('payback-period').textContent = paybackMonths + ' months';
    
    // Show results
    document.getElementById('roi-results').style.display = 'block';
}

// Smooth scrolling for anchor links
document.addEventListener('DOMContentLoaded', function() {
    // Initialize signup form if on contact page
    initializeSignupForm();
    
    // Auto-show form based on URL hash (for contact page)
    const hash = window.location.hash;
    const urlParams = new URLSearchParams(window.location.search);
    
    // Check for hash (with or without query params)
    if (hash.startsWith('#free') && document.getElementById('free-form')) {
        // Small delay to ensure everything is loaded
        setTimeout(() => {
            showForm('free');
            // Also handle plan parameter if present
            const plan = urlParams.get('plan');
            if (plan) {
                showPlanInfo(plan);
            }
        }, 100);
    } else if (hash.startsWith('#consultation') && document.getElementById('consultation-form')) {
        setTimeout(() => showForm('consultation'), 100);
    }
    const links = document.querySelectorAll('a[href^="#"]');
    
    links.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const targetSection = document.querySelector(targetId);
            if (targetSection) {
                const offset = 80; // Height of fixed nav
                const targetPosition = targetSection.getBoundingClientRect().top + window.scrollY - offset;
                
                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
                
                // Close mobile menu if it's open
                const navMenu = document.querySelector('.nav-menu');
                const mobileToggle = document.querySelector('.mobile-menu-toggle');
                if (navMenu && navMenu.classList.contains('active')) {
                    navMenu.classList.remove('active');
                    mobileToggle.classList.remove('active');
                    document.removeEventListener('click', closeMobileMenuOnOutsideClick);
                }
            }
        });
    });
    
    // Also add click handlers to ALL nav menu links to close mobile menu
    const navMenuLinks = document.querySelectorAll('.nav-menu a');
    navMenuLinks.forEach(link => {
        link.addEventListener('click', function() {
            const navMenu = document.querySelector('.nav-menu');
            const mobileToggle = document.querySelector('.mobile-menu-toggle');
            
            // Only close if it's actually the mobile menu (active state)
            if (navMenu && navMenu.classList.contains('active')) {
                // Small delay for anchor links to allow smooth scroll to start
                setTimeout(() => {
                    navMenu.classList.remove('active');
                    mobileToggle.classList.remove('active');
                    document.removeEventListener('click', closeMobileMenuOnOutsideClick);
                }, 100);
            }
        });
    });
    
    // Initialize ROI calculator listeners
    const roiInputs = document.querySelectorAll('.calculator-inputs input');
    roiInputs.forEach(input => {
        input.addEventListener('input', calculateROI);
    });
    
    // Add currency formatting to current-cost input
    const currentCostInput = document.getElementById('current-cost');
    if (currentCostInput) {
        // Format initial value
        currentCostInput.value = '$' + formatCurrency(currentCostInput.value);
        
        currentCostInput.addEventListener('input', function(e) {
            let value = e.target.value;
            // Remove existing formatting
            value = value.replace(/[^\d]/g, '');
            // Add formatting
            if (value) {
                e.target.value = '$' + formatCurrency(value);
            }
        });
        
        currentCostInput.addEventListener('blur', function(e) {
            let value = e.target.value.replace(/[^\d]/g, '');
            if (value) {
                e.target.value = '$' + formatCurrency(value);
            } else {
                e.target.value = '$0';
            }
        });
    }
    
    // Path card interactions (only for homepage, not contact page)
    const pathCards = document.querySelectorAll('.path-card[data-path]');
    pathCards.forEach(card => {
        // Only add navigation for cards with data-path attribute (homepage)
        // Skip contact page cards which have data-form attribute
        if (!card.hasAttribute('data-form')) {
            card.addEventListener('click', function() {
                const path = this.dataset.path;
                // Navigate to appropriate solution page
                if (path === 'augment') {
                    window.location.href = '/solutions/augmentation.html';
                } else if (path === 'replace') {
                    window.location.href = '/solutions/replacement.html';
                } else if (path === 'fresh') {
                    window.location.href = '/solutions/first-time.html';
                }
            });
        }
    });
    
    // Animate elements on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
            }
        });
    }, observerOptions);
    
    // Observe elements for animation
    const animatedElements = document.querySelectorAll('.path-card, .feature-item, .stat-item');
    animatedElements.forEach(el => {
        observer.observe(el);
    });
});

// Add animation styles dynamically
const style = document.createElement('style');
style.textContent = `
    .path-card, .feature-item, .stat-item {
        opacity: 0;
        transform: translateY(20px);
        transition: opacity 0.6s ease, transform 0.6s ease;
    }
    
    .animate-in {
        opacity: 1;
        transform: translateY(0);
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    
    .path-card.active {
        border-color: var(--primary-gradient-start);
        box-shadow: 0 10px 30px rgba(102, 126, 234, 0.2);
        transform: translateY(-5px);
    }
    
    .contact-form {
        background: white;
        border-radius: 1rem;
        padding: 2rem;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
    }
    
    .input-group select,
    .input-group textarea {
        padding: 0.75rem;
        border: 1px solid var(--border-light);
        border-radius: 0.5rem;
        font-size: 1rem;
        width: 100%;
        font-family: inherit;
    }
    
    .input-group select:focus,
    .input-group textarea:focus {
        outline: none;
        border-color: var(--primary-gradient-start);
    }
    
    /* Hover effect for Can't Decide cards */
    .features div[style*="transition: transform"] {
        cursor: pointer;
    }
    
    .features div[style*="transition: transform"]:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 30px rgba(0,0,0,0.15) !important;
    }
`;
document.head.appendChild(style);