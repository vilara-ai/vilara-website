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
    
    // Path card interactions
    const pathCards = document.querySelectorAll('.path-card');
    pathCards.forEach(card => {
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
`;
document.head.appendChild(style);