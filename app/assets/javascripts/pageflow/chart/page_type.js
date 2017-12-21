pageflow.react.registerPageTypeWithDefaultBackground('chart', {

  prepareNextPageTimeout: 0,

  enhance: function(pageElement, configuration) {
    var scroller = pageElement.find('.scroller');

    pageElement.find('.bigscreen_toggler').on('click', function() {
      $('body').toggleClass('bigScreen');
      scroller.scroller('refresh');
    });
    $('body').keydown(function(event) {
      if(event.keyCode == 27) {
        $(this).removeClass('bigScreen');
      }
    });
  },

  resize: function(pageElement, configuration) {
    var iframeWrapper = pageElement.find('.iframeWrapper');
    var pageHeader = pageElement.find('.page_header');
    var pageTitle = pageHeader.find('.title');
    var scroller = pageElement.find('.scroller');
    var fullWidth = configuration.full_width;

    pageElement.toggleClass('page-with_split_layout', !fullWidth);

    var splitLayout = pageflow.pageSplitLayout.pageIsWideEnough(pageElement) && !fullWidth;

    iframeWrapper.toggleClass('widescreened', splitLayout);

    if (splitLayout) {
      iframeWrapper.insertAfter(scroller);
    }
    else {
      iframeWrapper.insertAfter(pageHeader);
    }
  },

  customizeLayout: function(pageElement, configuration) {
    var that = this;
    var iframe = pageElement.find('iframe');
    var scroller = pageElement.find('.scroller');
    var iframeOverlay = pageElement.find('.iframe_overlay');

    if(!this.layoutCustomized) {
      iframe.load(function() {
        $(this).contents().find('.fs-btn').css('display','none');
        $(this).contents().find('body').addClass($("[data-theme]").attr('data-theme'));

        that._injectStylesheets($(this));

        if(pageflow.features.has('mobile platform')) {
          setTimeout(function() {
            if(iframe) {
              iframe.attr("height", iframe.contents().height() + "px");
              pageElement.find('.iframeWrapper').height(iframe.contents().height());
              scroller.scroller('refresh');
            }
          }, 1000);
        }
        scroller.scroller('refresh');
        pageElement.find('.iframeWrapper').addClass('active');
      });
      this.layoutCustomized = true;
    }
  },

  _injectStylesheets: function(iframe) {
    if (iframe.data('useCustomTheme')) {
      this._injectStylesheet(iframe, pageflow.chart.assetUrls.customStylesheet);
    }
    else {
      this._injectStylesheet(iframe, pageflow.chart.assetUrls.transparentBackgroundStylesheet);
    }
  },

  _injectStylesheet: function(iframe, path) {
    head = iframe.contents().find('head');
    head.append('<link rel="stylesheet" type="text/css" href="' + path + '">');
  },

  _initEventSimulation: function(element, iframe, wrapper) {
    element.on('click', function(event) {
      var contentElement = iframe.contents()[0];

      element.css('display', 'none');

      if (contentElement && event) {
        var offset = iframe.offset();
        var options = $.extend({}, event, {
          screenX: event.screenX - offset.left,
          screenY: event.screenY - offset.top,
          clientX: event.clientX - offset.left,
          clientY: event.clientY - offset.top,
        });

        var lastElement = $(contentElement.elementFromPoint(event.pageX - offset.left,
                                                            event.pageY - offset.top));

        lastElement.simulate('mousedown', options);
        lastElement.simulate('mousemove', options);
        lastElement.simulate('click', options);
        lastElement.simulate('mouseup', options);

        element.css('cursor', lastElement.css('cursor'));
      }

      element.css('display', 'block');

      event.preventDefault();
      event.stopPropagation();
    });

    iframe.load(function() {
      iframe.contents().find('*').on('mousemove', function() {
        wrapper.addClass('hovering');
      });

      iframe.contents().on('mouseout', function() {
        wrapper.removeClass('hovering');
      });
    });
  },

  prepare: function(pageElement, configuration) {
    this._loadIframe(pageElement);
  },

  activating: function(pageElement, configuration) {
    this._loadIframe(pageElement);
    this.resize(pageElement, configuration);
    this.customizeLayout(pageElement, configuration);
    this._initEventSimulation(pageElement.find('.iframe_overlay'), pageElement.find('iframe'), pageElement.find('.iframeWrapper'));
  },

  activated: function(pageElement, configuration) {},

  deactivating: function(pageElement, configuration) {
    $('body').removeClass('bigScreen');
  },

  deactivated: function(pageElement, configuration) {},

  update: function(pageElement, configuration) {
    pageElement.find('h2 .tagline').text(configuration.get('tagline') || '');
    pageElement.find('h2 .title').text(configuration.get('title') || '');
    pageElement.find('h2 .subtitle').text(configuration.get('subtitle') || '');
    pageElement.find('p').html(configuration.get('text') || '');

    pageElement.find('.shadow').css({
      opacity: configuration.get('gradient_opacity') / 100
    });

    if (configuration.hasChanged('full_width')) {
      $('body').removeClass('bigScreen');
    }

    this.resize(pageElement, configuration.attributes);
  },

  embeddedEditorViews: function() {
    return {
      'iframe': {
        view: pageflow.chart.IframeEmbeddedView,
        options: {propertyName: 'scraped_site_id'}
      }
    };
  },

  _loadIframe: function(pageElement) {
    pageElement.find('iframe[data-src]').each(function() {
      var iframe = $(this);

      if (!iframe.attr('src')) {
        iframe.attr('src', iframe.data('src'));
      }
    });
  }
});