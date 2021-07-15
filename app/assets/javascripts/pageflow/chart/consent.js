pageflow.chart.consent = {
  ensureVendorRegistered: function() {
    if (this.registered) {
      return;
    }

    this.registered = true;

    pageflow.consent.registerVendor('datawrapper', {
      paradigm: 'lazy opt-in',
      displayName: I18n.t('pageflow.public.chart.consent_vendor_name'),
      description: I18n.t('pageflow.public.chart.consent_vendor_description')
    });
  }
};
