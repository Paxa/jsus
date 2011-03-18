Feature: compression
  In order to minimize resulting file size, I should be able to use YUI
  compressor.
  Scenario: using the --compress option
    When I run "jsus Compression tmp --compress"
    Then the following files should exist:
      | tmp/compression.js |
      | tmp/compression.min.js |
    And file "tmp/compression.min.js" should not contain
      """
      /*
      """
    And file "tmp/compression.min.js" should not contain
      """
      */
      """
    And file "tmp/compression.min.js" should contain
      """
      var Input
      """
    And file "tmp/compression.min.js" should contain
      """
      var Color
      """