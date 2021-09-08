pageflow.chart.IframeEmbeddedView = Backbone.Marionette.View.extend({
  modelEvents: {
    'change': 'update'
  },

  render: function() {
    if (this.model.has('chart_url')) {
      this.updateChartUrl();
    }
    else if (this.model.has('scraped_site_id')) {
      this.updateScrapedSite();
    }

    return this;
  },

  update: function() {
    if (this.model.hasChanged('chart_url')) {
      this.updateChartUrl();
    }
    else if (this.model.hasChanged('scraped_site_id')) {
      this.updateScrapedSite();
    }
  },

  updateChartUrl: function() {
    this.$el.attr('src', this.model.get('chart_url'));
    this.$el.removeAttr('data-use-custom-theme');
    this.$el.removeAttr('data-customize-layout');
  },

  updateScrapedSite: function() {
    if (this.scrapedSite) {
      this.stopListening(this.scrapedSite);
    }

    this.scrapedSite = this.model.getReference('scraped_site_id',
                                               'pageflow_chart_scraped_sites');
    this.updateAttributes();

    if (this.scrapedSite) {
      this.listenTo(this.scrapedSite, 'change', this.updateAttributes);
    }
  },

  updateAttributes: function() {
    var scrapedSite = this.scrapedSite;

    if (scrapedSite && scrapedSite.isReady()) {
      this.$el.attr('src', scrapedSite.get('html_file_url'));
      this.$el.attr('data-customize-layout', 'true');

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
