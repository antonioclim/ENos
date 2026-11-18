/* Source fallback only; browser acceptance is recorded separately. */
(function () {
  'use strict';
  function checkPresentation() {
    if (typeof window.Reveal !== 'undefined' && typeof window.Reveal.isReady === 'function' && window.Reveal.isReady()) return;
    document.documentElement.classList.add('enos-static-presentation');
    if (document.getElementById('enos-resource-status')) return;
    var notice = document.createElement('p');
    notice.id = 'enos-resource-status';
    notice.className = 'enos-resource-status';
    notice.setAttribute('role', 'status');
    notice.textContent = 'Presentation navigation could not initialise. The slides are shown as a readable document. Keep the companion assets directory with this file.';
    document.body.insertBefore(notice, document.body.firstChild);
  }
  if (document.readyState === 'complete') checkPresentation();
  else window.addEventListener('load', checkPresentation, {once: true});
}());
