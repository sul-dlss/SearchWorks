export default function() {
  if (!window.opener) return;

  const node = document.createElement('div');
  node.appendChild(this.templateContent);
  window.opener.dispatchEvent(new CustomEvent('show-toast', { detail: { html: node.innerHTML } }));

  window.close();
}
