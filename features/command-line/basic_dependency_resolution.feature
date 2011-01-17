Feature: resolve dependencies
  In order to resolve dependencies, jsus should use topological sort on the
  dependency list.

  Scenario: internal dependencies in correct order
    When I run "jsus -i Basic -o tmp"
    Then the following files should exist:
      | tmp/package.js |
    And file "tmp/package.js" should contain
      """
      /*
      ---

      script: Color.js

      description: A library to work with colors

      license: MIT-style license

      authors:
      - Valerio Proietti

      provides: [Color]

      ...
      */
      /*
      ---

      script: Input.Color.js

      description: Cool colorpicker for everyone to enjoy

      license: MIT-style license

      authors:
      - Yaroslaff Fedin

      requires:
      - Color

      provides: [Input.Color]

      ...
      */
      """