// External browsers do not share the HA app's ingress cookie. Use Homebox's
// existing download link when opening a stored attachment through ingress.
document.addEventListener("click", (event) => {
    if (event.defaultPrevented || event.button !== 0 || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) {
        return;
    }

    const link = event.target instanceof Element
        ? event.target.closest('a[target="_blank"]')
        : null;
    const download = link?.closest("li")?.querySelector("a[download]");
    if (!download || download.href !== link.href) {
        return;
    }

    const url = new URL(link.href);
    if (url.origin !== location.origin || !/\/api\/v1\/entities\/[^/]+\/attachments\/[^/]+$/.test(url.pathname)) {
        return;
    }

    event.preventDefault();
    download.click();
}, true);
