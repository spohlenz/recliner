Recliner
========

Recliner is a Ruby ORM for interfacing with [CouchDB](http://couchdb.apache.org/) databases.

It is designed to be familiar to users of ActiveRecord and DataMapper, but diverges where necessary to fit with the CouchDB document/view paradigm.


Installation
============

Recliner is distributed as a gem. Install with:

    gem install recliner


Sample Usage
============

    require 'recliner'

    Recliner::Document.use_database 'http://localhost:5984/my-database-location'

    class Article < Recliner::Document
      property :title, String, :default => 'Untitled'
      property :body, String
      property :published_at, Time, :protected => true
      property :approved, Boolean, :default => false, :protected => true
      timestamps!

      validates_presence_of :title, :body
      
      has :author, :class_name => 'User'

      default_order :published_at

      view :by_title, :order => :title
      view :approved, :conditions => { :approved => true }      
    end
