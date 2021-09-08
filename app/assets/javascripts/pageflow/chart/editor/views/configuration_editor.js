pageflow.ConfigurationEditorView.register('chart', {
  configure: function() {
    var supportedHosts = this.options.pageType.supportedHosts;

    this.tab('general', function() {
      this.group('general');
    });

    this.tab('files', function() {
      this.input('chart_url', pageflow.UrlInputView, {
        displayPropertyName: 'display_scraped_site_url',
        supportedHosts: supportedHosts,
        required: true,
        permitHttps: true
      });

      this.view(pageflow.chart.DatawrapperAdView);
      this.input('full_width', pageflow.CheckBoxInputView);
      this.group('background');
      this.input('thumbnail_image_id', pageflow.FileInputView, {
        collection: pageflow.imageFiles,
        imagePositioning: false
      });
    });

    this.tab('options', function() {
      this.group('options');
    });
  }
});
