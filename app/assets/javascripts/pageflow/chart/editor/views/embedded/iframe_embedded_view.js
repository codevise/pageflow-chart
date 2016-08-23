pageflow.chart.IframeEmbeddedView = Backbone.Marionette.View.extend({
  modelEvents: {
    'change': 'update'
  },

  render: function() {
    this.updateScrapedSite();
    return this;
  },

  update: function() {
    if (this.model.hasChanged(this.options.propertyName)) {
      this.updateScrapedSite();
    }
  },

  updateScrapedSite: function() {
    var view = this;

    if (this.scrapedSite) {
      this.stopListening(this.scrapedSite);
    }

    var scrapedSiteId = this.model.get(this.options.propertyName);

    if (scrapedSiteId) {
      this.scrapedSite = pageflow.chart.scrapedSites.getOrFetch(scrapedSiteId, {
        success: function(scrapedSite) {
          view.updateAttributes(scrapedSite);
        }
      });

      this.listenTo(this.scrapedSite, 'change', this.updateAttributes);
    }
  },

  updateAttributes: function(scrapedSite) {
    scrapedSite = scrapedSite || this.scrapedSite;

    if (scrapedSite && scrapedSite.isProcessed()) {
      this.$el.attr('src', scrapedSite.get('html_file_url'));

      if (scrapedSite.get('use_custom_theme')) {
        this.$el.attr('data-use-custom-theme', 'true');
      }
      else {
        this.$el.removeAttr('data-use-custom-theme');
      }
    }
    else {
      this.$el.attr('src', '');
    }
  }
});