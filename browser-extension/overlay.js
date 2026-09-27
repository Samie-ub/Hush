(() => {
  if (globalThis.__notchFocusInstalled) return;
  globalThis.__notchFocusInstalled = true;
  let cover;
  let lease = 0;
  function clear() { cover?.remove(); cover = undefined; lease = 0; }
  function update(state) {
    const host = location.hostname.toLowerCase().replace(/\.$/, '');
    const matches = state?.active && state.expiresAt > Date.now() / 1000 &&
      state.domains?.some(domain => host === domain || host.endsWith('.' + domain));
    if (!matches) { clear(); return; }
    lease = state.expiresAt;
    if (cover?.isConnected || !document.documentElement) return;
    cover = document.createElement('dialog');
    cover.setAttribute('aria-label', 'Hush Mode');
    cover.style.cssText = 'position:fixed!important;inset:0!important;width:100vw!important;height:100vh!important;max-width:none!important;max-height:none!important;margin:0!important;padding:0!important;border:0!important;background:#131f26!important;color:#edf6f0!important;';
    const container = document.createElement('div');
    container.style.height = '100%';
    cover.append(container);
    const shadow = container.attachShadow({ mode: 'closed' });
    const style = document.createElement('style');
    style.textContent = ':host{color-scheme:dark}section{height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;font:16px -apple-system,BlinkMacSystemFont,system-ui,sans-serif;padding:32px;box-sizing:border-box}h1{font-size:32px;letter-spacing:-.04em}p{max-width:420px;color:#aabbb5;line-height:1.6}small{color:#78edba;letter-spacing:.15em;font-size:10px;font-weight:700}.mark{display:block;width:52px;height:52px;margin-bottom:24px;border-radius:12px}';
    const section = document.createElement('section');
    const mark = document.createElement('img'); mark.className = 'mark'; mark.src = chrome.runtime.getURL('icon128.png'); mark.alt = '';
    const eyebrow = document.createElement('small'); eyebrow.textContent = 'HUSH MODE';
    const title = document.createElement('h1'); title.textContent = 'Focus session active';
    const description = document.createElement('p'); description.textContent = 'Your page is still here. Pause or finish the timer to return to it.';
    section.append(mark, eyebrow, title, description); shadow.append(style, section);
    cover.addEventListener('cancel', event => event.preventDefault());
    document.documentElement.append(cover);
    cover.showModal();
  }
  chrome.runtime.onMessage.addListener(message => { if (message.type === 'focus') update(message.state); });
  async function refresh() {
    if (lease && Date.now() / 1000 >= lease) clear();
    try { update(await chrome.runtime.sendMessage({ type: 'status' })); }
    catch { clear(); }
  }
  setInterval(refresh, 1000);
  addEventListener('pageshow', refresh);
  addEventListener('focus', refresh);
  void refresh();
})();
