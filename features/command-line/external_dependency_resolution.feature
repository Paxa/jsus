Feature: external dependencies
  In order to resolve dependencies, jsus should be able to preload them into
  pool.
  
  Scenario: basic external dependency
    When I run "jsus -i ExternalDependency -o tmp -d ExternalDependency/Mootools"
    Then the following files should exist:
      | tmp/package.js |
    And file "tmp/package.js" should contain
      """
      /*
      ---

      script: Core.js

      description: Mootools fake core

      license: MIT-style license

      authors:
      - Valerio Proietti

      provides: [Core]

      ...
      */
      """
    And file "tmp/package.js" should contain
      """
      /*
      ---

      script: Color.js

      description: A library to work with colors

      license: MIT-style license

      authors:
      - Valerio Proietti

      requires:
        - Mootools/Core

      provides: [Color]

      ...
      */
      """
    And file "tmp/package.js" should have "script: Core.js" before "script: Color.js"