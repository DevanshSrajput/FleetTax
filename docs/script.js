// Theme Management
const themeToggle = document.getElementById('themeToggle');
const htmlElement = document.documentElement;
const body = document.body;

// Check for saved theme preference or default to light mode
const currentTheme = localStorage.getItem('theme') || 'light-theme';

// Apply saved theme on page load
if (currentTheme === 'dark-theme') {
    body.classList.add('dark-theme');
    themeToggle.textContent = '☀️';
} else {
    body.classList.remove('dark-theme');
    themeToggle.textContent = '🌙';
}

// Toggle theme on button click
themeToggle.addEventListener('click', () => {
    const isDarkTheme = body.classList.toggle('dark-theme');
    
    // Update button icon
    themeToggle.textContent = isDarkTheme ? '☀️' : '🌙';
    
    // Save preference to localStorage
    localStorage.setItem('theme', isDarkTheme ? 'dark-theme' : 'light-theme');
    
    // Add animation to toggle button
    themeToggle.style.animation = 'none';
    setTimeout(() => {
        themeToggle.style.animation = 'spinRotate 0.3s ease-out';
    }, 10);
});

// Add spinning animation for theme toggle
const style = document.createElement('style');
style.textContent = `
    @keyframes spinRotate {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    
    @keyframes pulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
    }
`;
document.head.appendChild(style);

// Smooth scroll behavior for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (href !== '#' && document.querySelector(href)) {
            e.preventDefault();
            document.querySelector(href).scrollIntoView({
                behavior: 'smooth'
            });
        }
    });
});

// Add active state to navbar links based on scroll position
window.addEventListener('scroll', () => {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-links a[href^="#"]');
    
    let current = '';
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (pageYOffset >= sectionTop - 200) {
            current = section.getAttribute('id');
        }
    });
    
    navLinks.forEach(link => {
        link.style.borderBottom = 'none';
        if (link.getAttribute('href').slice(1) === current) {
            link.style.borderBottom = '2px solid var(--accent-yellow)';
            link.style.color = 'var(--accent-yellow)';
        }
    });
});

// Add scroll animation to elements
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all feature cards and other elements
document.querySelectorAll('.feature-card, .tech-item, .status-item, .developer-card').forEach(element => {
    element.style.opacity = '0';
    element.style.transform = 'translateY(20px)';
    element.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
    observer.observe(element);
});

// Add parallax effect to hero section on scroll
const heroSection = document.querySelector('.hero');
if (heroSection) {
    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;
        heroSection.style.backgroundPosition = `0 ${scrolled * 0.5}px`;
    });
}

// Interactive button animations
document.querySelectorAll('.btn').forEach(button => {
    button.addEventListener('mouseenter', function() {
        this.style.textDecoration = 'underline';
    });
    
    button.addEventListener('mouseleave', function() {
        this.style.textDecoration = 'none';
    });
});

// Add ripple effect to buttons on click
document.querySelectorAll('.btn, .social-link, .doc-link').forEach(element => {
    element.addEventListener('click', function(e) {
        const ripple = document.createElement('span');
        const rect = this.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        const x = e.clientX - rect.left - size / 2;
        const y = e.clientY - rect.top - size / 2;
        
        ripple.style.width = ripple.style.height = size + 'px';
        ripple.style.left = x + 'px';
        ripple.style.top = y + 'px';
        ripple.classList.add('ripple');
        
        this.appendChild(ripple);
        
        setTimeout(() => ripple.remove(), 600);
    });
});

// Add ripple styles
const rippleStyle = document.createElement('style');
rippleStyle.textContent = `
    .btn, .social-link, .doc-link {
        position: relative;
        overflow: hidden;
    }
    
    .ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.6);
        transform: scale(0);
        animation: rippleAnimation 0.6s ease-out;
        pointer-events: none;
    }
    
    @keyframes rippleAnimation {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
`;
document.head.appendChild(rippleStyle);

// Mobile menu toggle (if needed)
function setupMobileMenu() {
    const navLinks = document.querySelector('.nav-links');
    const menuButton = document.querySelector('.menu-toggle');
    
    if (menuButton) {
        menuButton.addEventListener('click', () => {
            navLinks.classList.toggle('active');
        });
    }
}

setupMobileMenu();

// Add keyboard navigation
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        // Close any open menus
        const navLinks = document.querySelector('.nav-links');
        if (navLinks) {
            navLinks.classList.remove('active');
        }
    }
});

// Performance optimization: Debounce scroll events
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Optimize scroll performance
const debouncedScroll = debounce(() => {
    // Scroll animations already handled
}, 100);

window.addEventListener('scroll', debouncedScroll);

// Accessibility: Set focus styles
document.addEventListener('keydown', (e) => {
    if (e.key === 'Tab') {
        document.body.classList.add('keyboard-navigation');
    }
});

document.addEventListener('mousedown', () => {
    document.body.classList.remove('keyboard-navigation');
});

// Add accessibility styles
const a11yStyle = document.createElement('style');
a11yStyle.textContent = `
    body.keyboard-navigation a:focus,
    body.keyboard-navigation .btn:focus,
    body.keyboard-navigation .theme-toggle:focus {
        outline: 3px solid var(--accent-yellow);
        outline-offset: 2px;
    }
`;
document.head.appendChild(a11yStyle);

// Console message for fun
console.log('%cFleetTax 🚍', 'color: #ff6b35; font-size: 20px; font-weight: bold;');
console.log('%cVahan Road Tax Tracker for Fleet Owners', 'color: #00ffff; font-size: 14px;');
console.log('%cMade by Devansh Singh', 'color: #00e676; font-size: 12px;');
console.log('%cGitHub: https://github.com/DevanshSrajput', 'color: #999; font-size: 11px;');
