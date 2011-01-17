Feature: json package files
  In order to be compliant with mooforge packages, we should accept 
  package.json 

  Scenario: package with package.json file
    When I run "jsus -i JsonPackage -o tmp"
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
      """
    And file "tmp/package.js" should contain
      """
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
    And file "tmp/package.js" should have "script: Color.js" before "script: Input.Color.js"