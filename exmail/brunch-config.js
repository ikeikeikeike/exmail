exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"

      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //  "js/app.js": /^(web\/static\/js)/,
      //  "js/vendor.js": /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // order: {
      //   before: [
      //     "web/static/vendor/js/jquery-2.1.1.js",
      //     "web/static/vendor/js/bootstrap.min.js"
      //   ]
      // }
    },
    stylesheets: {
      joinTo: {
        'css/app.css': /^(web\/static\/css|bower_components|node_modules)/
      },
      order: {
        before: [
        ]
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static",
      "deps/phoenix/web/static",
      "deps/phoenix_html/web/static",
      "web/static",
      "test/static",

      // "bower_components/flatpickr/dist/rtl",
      // "bower_components/flatpickr/dist/l10n",
      // "bower_components/flatpickr/dist/plugins",
      // "bower_components/flatpickr/dist/themes",

      "bower_components/font-awesome/css",
      "bower_components/slick-carousel/slick",
      "bower_components/bootstrap/dist/css/bootstrap.min.css",

      "bower_components/prism/components/prism-python.min.js",
      "bower_components/prism/components/prism-ruby.min.js",
      "bower_components/prism/components/prism-wiki.min.js",
      "bower_components/prism/plugins/line-numbers",
      "bower_components/prism/themes/prism.css",
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    afterBrunch: [
      'mkdir -p priv/static/fonts',
      'cp -f bower_components/bootstrap/fonts/* priv/static/fonts',
      'cp -f bower_components/font-awesome/fonts/* priv/static/fonts',

      'mkdir -p priv/static/css/fonts',
      'cp -f bower_components/icomoon-bower/fonts/* priv/static/css/fonts',
      'cp -f bower_components/slick-carousel/slick/fonts/* priv/static/css/fonts',
      'cp -f bower_components/slick-carousel/slick/ajax-loader.gif priv/static/css/',

      'mkdir -p priv/static/flags',
      'cp -pRf bower_components/flag-icon-css/flags/* priv/static/flags',

      'ln -sfn priv/static/uploads',
    ]
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  npm: {
    enabled: true
  }
};
