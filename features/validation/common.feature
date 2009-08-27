Feature: Common validation options
  Every validation supports a number of options:
    :on      => specifies when the validation should run (either :update, :create or :save [default])
    :message => sets a custom error message
    :if      => only runs the validation if the given method, proc or string evaluates to true
    :unless  => only runs the validation if the given method, proc or string evaluates to false
  
  Scenario: :on => :create when creating
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        validates_presence_of :title, :on => :create
      end
      """
    When I create an instance of "Article"
    Then the instance should not be valid
    
  Scenario: :on => :create when updating
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        validates_presence_of :title, :on => :create
      end
      """
    Given I have a saved instance of "Article" with:
      | title | The title |
    And I set its title to ""
    Then the instance should be valid
  
  Scenario: :on => :update when creating
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        validates_presence_of :title, :on => :update
      end
      """
    When I create an instance of "Article"
    Then the instance should be valid
  
  Scenario: :on => :update when updating
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        validates_presence_of :title, :on => :update
      end
      """
    Given I have a saved instance of "Article" with:
      | title | The title |
    And I set its title to ""
    Then the instance should not be valid
  
  Scenario: custom message
    Given the following document definition:
    """
    class Article < Recliner::Document
      property :title, String
      validates_presence_of :title, :message => 'has a custom message'
    end
    """
    When I create an instance of "Article"
    Then the instance should not be valid
    And its errors should include "Title has a custom message"
  
  Scenario Outline: :if returns true
    Given the following document definition:
    """
    class Article < Recliner::Document
      property :title, String
      validates_presence_of :title, :if => <if_condition>
      
      def method_returning_true
        true
      end
    end
    """
    When I create an instance of "Article"
    Then the instance should not be valid
    
    Examples:
      | if_condition           |
      | lambda { true }        |
      | :method_returning_true |
      | "true"                 |
  
  Scenario Outline: :if returns false
    Given the following document definition:
    """
    class Article < Recliner::Document
      property :title, String
      validates_presence_of :title, :if => <if_condition>
      
      def method_returning_false
        false
      end
    end
    """
    When I create an instance of "Article"
    Then the instance should be valid
    
    Examples:
      | if_condition            |
      | lambda { false }        |
      | :method_returning_false |
      | "false"                 |
  
  Scenario Outline: :unless returns true
    Given the following document definition:
    """
    class Article < Recliner::Document
      property :title, String
      validates_presence_of :title, :unless => <unless_condition>
      
      def method_returning_true
        true
      end
    end
    """
    When I create an instance of "Article"
    Then the instance should be valid
    
    Examples:
      | unless_condition       |
      | lambda { true }        |
      | :method_returning_true |
      | "true"                 |
  
  Scenario Outline: :unless returns false
    Given the following document definition:
    """
    class Article < Recliner::Document
      property :title, String
      validates_presence_of :title, :unless => <unless_condition>
      
      def method_returning_false
        false
      end
    end
    """
    When I create an instance of "Article"
    Then the instance should not be valid
    
    Examples:
      | unless_condition        |
      | lambda { false }        |
      | :method_returning_false |
      | "false"                 |
      