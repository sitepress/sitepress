// Copy error text to clipboard
function copyError(btn) {
  var errorText = document.getElementById('error-text');
  if (!errorText) return;

  navigator.clipboard.writeText(errorText.textContent).then(function() {
    var original = btn.innerHTML;
    btn.innerHTML = '<svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Copied';
    btn.classList.add('copy-btn--success');
    setTimeout(function() {
      btn.innerHTML = original;
      btn.classList.remove('copy-btn--success');
    }, 2000);
  });
}

// Load source code when clicking stack trace lines
function loadSource(el) {
  var file = el.dataset.file;
  var line = el.dataset.line;
  if (!file || !line) return;

  // Update selection
  document.querySelectorAll('.trace-line--selected').forEach(function(t) {
    t.classList.remove('trace-line--selected');
  });
  el.classList.add('trace-line--selected');

  // Check if source viewer is available
  var sourceLines = document.getElementById('source-lines');
  var sourceTitle = document.getElementById('source-title');
  if (!sourceLines || !sourceTitle) return;

  // Fetch source
  fetch('/_sitepress/source?file=' + encodeURIComponent(file) + '&line=' + encodeURIComponent(line))
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data.error) {
        sourceLines.innerHTML = '<div class="source-line"><span class="source-line__code">' + escapeHtml(data.error) + '</span></div>';
        return;
      }

      var html = '';
      data.lines.forEach(function(l) {
        var cls = 'source-line' + (l.error ? ' source-line--error' : '');
        html += '<div class="' + cls + '"><span class="source-line__num">' + l.number + '</span><span class="source-line__code">' + escapeHtml(l.code) + '</span></div>';
      });
      sourceLines.innerHTML = html;
      sourceTitle.textContent = data.file + ':' + data.line;
    })
    .catch(function(e) {
      sourceLines.innerHTML = '<div class="source-line"><span class="source-line__code">Error loading source</span></div>';
    });
}

function escapeHtml(text) {
  var div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}
