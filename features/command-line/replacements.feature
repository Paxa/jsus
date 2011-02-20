Feature: replacements
  In order to monkeypatch other libraries, I should be able to replace some
  of the files.
  
  Scenario: monkeypatch for external dependency
    When I run "jsus Replacements tmp -d Replacements"
    Then the following files should exist:
      | tmp/package.js |
    And file "tmp/package.js" should contain
      """
      /*
      ---

      script: MootooolsCore.js

      description: Replaced mootools core

      license: MIT-style license

      authors:
      - Mark Abramov

      provides: 
        - More

      replaces: Mootools/Core

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
    And file "tmp/package.js" should not contain
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
    And file "tmp/package.js" should have "MootooolsCore.js" before "script: Color.js"
