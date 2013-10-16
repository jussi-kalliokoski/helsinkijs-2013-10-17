module.exports = (grunt) ->
  _ = grunt.util._

  config = require("./config/build")
  config.environment = process.env.NODE_ENV or "local"
  config.package = require("./package.json")

  gruntConfig = _.extend {}, config,
    clean:
      coverage:
        src: ["dist/coverage"]
      temporary:
        src: ["<%= tempDir %>"]
      public:
        src: ["public"]
    coffee:
      unit:
        files: [{
          src: "tests/unit/**/*.coffee"
          dest: "<%= tempDir %>/tests/unit.js"
        }]
    concat:
      js:
        dest: "public/assets/js/app.js"
        src: [
          "<%= vendorJavascripts %>"
          "<%= javascripts %>"
          "<%= tempDir %>/js/templates.js"
        ]
      css:
        dest: "public/assets/css/app.css"
        src: [
          "<%= tempDir %>/css/app.css"
          "app/fonts/fonts.css"
        ]
    connect:
      default:
        options:
          port: 8080
          base: "./public"
    copy:
      indexPage:
        src: "app/index.html"
        dest: "public/index.html"
      fonts:
        expand: true
        cwd: "app/"
        src: "fonts/**/*.{eot,svg,ttf,woff}"
        dest: "public/assets"
      images:
        expand: true
        cwd: "app/"
        src: "images/**"
        dest: "public/assets/"
      templates:
        expand: true
        cwd: "app/"
        src: "templates/**"
        dest: "<%= tempDir %>/"
    coverage:
      options:
        thresholds:
          statements: 50
          branches: 50
          lines: 50
          functions: 50
        dir: "dist/coverage"
    csslint:
      options:
        csslintrc: ".csslintrc"
      compiled:
        src: ["<%= tempDir %>/css/app.css"]
    htmlmin:
      options:
        removeComments: true
        removeAttributeQuotes: true
        collapseWhitespace: true
      templates:
        files: [{
          cwd: "<%= tempDir %>/templates"
          expand: true
          src: ["*.html"]
          dest: "<%= tempDir %>/templates"
        }]
      html:
        files:
          "public/index.html": "public/index.html"
    jshint:
      default:
        src: ["<%= javascripts %>"]
        options:
          jshintrc: "<%= jshintrc %>"
    karma:
      unitDev:
        configFile: "config/karma/unit.conf.coffee"
      unitProduction:
        configFile: "config/karma/production.unit.conf.coffee"
    plato:
      all:
        options:
          jshint:
            options:
              jshintrc: config.jshintrc
          complexity:
            logicalor: false
            switchcase: false
            forin: true
            trycatch: true
        files:
          "dist/report": ["<%= javascripts %>"]
    prangler:
      templates:
        options:
          ngApp: "ourApp"
          stripPathForTemplateId: "<%= tempDir %>/templates/"
        files: [{
          src: ["<%= tempDir %>/templates/*.html"]
          dest: "<%= tempDir %>/js/templates.js"
        }]
    rev:
      options:
        algorithm: "sha1"
        length: 16
      assets:
        src: ["public/assets/{fonts,images}/**/*.{jpg,jpeg,png,webp,eot,svg,ttf,woff}"]
      js:
        src: ["public/assets/js/*.js"]
      css:
        src: ["public/assets/css/*.css"]
    stylus:
      default:
        options: {}
        files: [{
          src: ["<%= stylesheets %>"]
          dest: "<%= tempDir %>/css/app.css"
        }]
    uglify:
      options:
        report: "min"
      production:
        files: [{
          dest: "public/assets/js/app.js"
          src: [
            "<%= vendorJavascripts %>"
            "<%= javascripts %>"
            "<%= tempDir %>/js/templates.js"
          ]
        }]
    useminPrepare:
      html: ["public/index.html", "<%= tempDir %>/templates/*.html"]
    usemin:
      options:
        dirs: ["public/assets"]
      html: ["public/index.html"]
      css: ["public/assets/css/*.css"]
      templates:
        options:
          type: "html"
        files:
          html: ["<%= tempDir %>/templates/*.html"]
    watch:
      dev:
        options:
          atBegin: true
        files: ["app/**/*"]
        tasks: "build:dev"
      production:
        options:
          atBegin: true
        files: ["app/**/*"]
        tasks: ["clean", "build:production"]

  # Dump config for debugging
  grunt.log.verbose.writeln("Config dump: " + JSON.stringify(config, null, "  "))

  grunt.initConfig(gruntConfig)

  # load all grunt tasks based on package.json
  gruntTasks = _
    .map(config.package.devDependencies, (version, name) -> name)
    .filter( (name) -> /^grunt-(?!cli)/.test(name) )
    .forEach( (task) -> grunt.loadNpmTasks(task) )

  # composite tasks and aliases
  grunt.registerTask("compile:js", [
    "prangler",
    "concat:js"
  ])

  grunt.registerTask("compile:css", [
    "stylus",
    "concat:css"
  ])

  grunt.registerTask("compile:html", [
    "copy:indexPage"
  ])

  grunt.registerTask("compile:assets", [
    "copy:fonts",
    "copy:images"
  ])

  grunt.registerTask("compile:templates", [
    "copy:templates"
  ])

  grunt.registerTask("minify:js", [
    "compile:js",
    "uglify",
    "rev:js"
  ])

  grunt.registerTask("minify:css", [
    "compile:css",
    "usemin:css",
    "rev:css"
  ])

  grunt.registerTask("minify:html", [
    "compile:html",
    "usemin:html",
    "htmlmin:html"
  ])

  grunt.registerTask("minify:assets", [
    "compile:assets",
    "rev:assets"
  ])

  grunt.registerTask("minify:templates", [
    "compile:templates",
    "usemin:templates",
    "htmlmin:templates"
  ])

  grunt.registerTask("build:dev", [
    "compile:assets",
    "compile:css",
    "compile:templates",
    "compile:js",
    "compile:html"
  ])

  grunt.registerTask("build:production", [
    "useminPrepare",
    "minify:assets",
    "minify:css",
    "minify:templates",
    "minify:js",
    "minify:html"
  ])

  grunt.registerTask("clean:build", [
    "clean:temporary",
    "clean:public"
  ])

  grunt.registerTask("test:dev", [
    "clean:coverage",
    "coffee:unit",
    "karma:unitDev",
    "coverage"
  ])

  grunt.registerTask("test:production", [
    "clean:build",
    "build:production",
    "coffee:unit",
    "karma:unitProduction"
  ])

  grunt.registerTask("test:lint", [
    "jshint",
    "csslint"
  ])

  grunt.registerTask("test", [
    "build:dev",
    "test:lint",
    "test:dev",
    "test:production"
  ])

  grunt.registerTask("dev", [
    "connect",
    "watch:dev"
  ])

  grunt.registerTask("production", [
    "connect",
    "watch:production"
  ])

  grunt.registerTask("precommit", [
    "test"
  ])
