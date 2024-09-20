window.addEventListener('scroll', function() {
    const elements = document.querySelectorAll('.scroll-reveal');
    elements.forEach(element => {
        const position = element.getBoundingClientRect();
        if (position.top < window.innerHeight && position.bottom >= 0) {
            element.classList.add('visible');
        }
    });
});
