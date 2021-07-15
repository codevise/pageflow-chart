pageflow.chart.consent = {
  ensureVendorRegistered: function(options) {
    if (this.registered) {
      return;
    }

    this.registered = true;
    options = options || {}

    pageflow.consent.registerVendor('datawrapper', {
      paradigm: options.skip ? 'skip' : 'lazy opt-in',
      displayName: I18n.t('pageflow.public.chart.consent_vendor_name'),
      description: I18n.t('pageflow.public.chart.consent_vendor_description')
    });
  }
};
