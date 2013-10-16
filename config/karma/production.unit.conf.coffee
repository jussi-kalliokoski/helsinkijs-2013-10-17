_ = require('lodash')

module.exports = (config) ->
  buildConfig = require('../build.json')

  karmaConfig = _.extend _.cloneDeep(buildConfig.karmaDefaults),
    files: _.flatten [
      buildConfig.karmaDefaults.files
      ['public/assets/js/*.js']
      ['tests/vendor/angular-mocks.js']
      ["#{buildConfig.tempDir}/tests/unit.js"]
    ]
    colors: buildConfig.isTeamCity

  config.set(karmaConfig)
