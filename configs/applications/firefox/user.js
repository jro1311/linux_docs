/* PRIVACY **/
user_pref("browser.contentblocking.category", "strict");
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("privacy.resistFingerprinting", false);

/* HTTPS-ONLY MODE **/
user_pref("dom.security.https_only_mode", true);

/* SAFE BROWSING **/
user_pref("browser.safebrowsing.downloads.remote.enabled", false);

/* TELEMETRY **/
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);

/* DISK AVOIDANCE **/
user_pref("browser.cache.disk.enable", false);
user_pref("browser.cache.memory.enable", true);
user_pref("browser.cache.memory.capacity", 131072);
user_pref("browser.cache.memory.max_entry_size", 2048);
user_pref("media.memory_cache_max_size", 65536);
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true);
user_pref("browser.sessionstore.resume_from_crash", false);
user_pref("browser.sessionstore.interval", 300000);

/* MOZILLA UI **/
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.aboutwelcome.enabled", false);

/* FULLSCREEN **/
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
user_pref("full-screen-api.warning.timeout", 1000);

/* URL BAR **/
user_pref("browser.urlbar.trending.featureGate", false);

/* NEW TAB PAGE **/
user_pref("browser.newtabpage.activity-stream.default.sites", "");
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);

/* DOWNLOADS **/
user_pref("browser.download.manager.addToRecentDocs", false);

/* PDF **/
user_pref("browser.download.open_pdf_attachments_inline", true);

/* TAB BEHAVIOR **/
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("browser.menu.showViewImageInfo", true);
user_pref("findbar.highlightAll", true);
user_pref("layout.word_select.eat_space_to_next_word", false);

/* LIBREWOLF **/
user_pref("librewolf.webgl.prompt", false);
