#
# Cookbook Name:: Drupal Solr
# Recipe:: default
#
# Copyright 2012, Dracars Designs
#
# All rights reserved - Do Not Redistribute
#
# To-Do add attributes to abstract values

include_recipe "drupal"
include_recipe "solr"

 package "unzip"

  directory "#{ node['drupal']['dir'] }/sites/all/libraries" do
    mode 0755
    action :create
    not_if do
      File.exists?("#{ node['drupal']['dir'] }/sites/all/libraries")
    end
  end

  remote_file "#{ node['drupal']['dir'] }/sites/all/libraries/SolrPhpClient.r60.2011-05-04.zip" do
    source "http://solr-php-client.googlecode.com/files/SolrPhpClient.r60.2011-05-04.zip"
        not_if do
      File.exists?("SolrPhpClient.r60.2011-05-04.zip")
    end
  end

  execute "unzip-solr-php-library" do
    cwd "#{ node['drupal']['dir'] }/sites/all/libraries"
    command "unzip SolrPhpClient.r60.2011-05-04.zip && rm -rf SolrPhpClient.r60.2011-05-04.zip"
    not_if do
      File.exists?("#{ node['drupal']['dir'] }/sites/all/libraries/SolrPhpClient")
    end
  end

  execute "rename-old-solr-config-files" do
    cwd "/usr/local/share/apache-solr/example/solr/conf"
    command "mv schema.xml schema-01.xml; \
             mv solrconfig.xml solrconfig-01.xml; \
             mv protwords.txt protwords-01.txt;"
    not_if do
      File.exists?("/usr/local/share/apache-solr/example/solr/conf/schema-01.xml")
    end
  end

  execute "copy-new-solr-conf-files" do
    cwd "/usr/local/share/apache-solr/example/solr/conf"
    command "SCHEMA=`find #{ node['drupal']['dir'] } -name schema.xml`; \
             CONFIG=`find #{ node['drupal']['dir'] } -name solrconfig.xml`; \
             cp $SCHEMA .; \
             cp $CONFIG .;"
    notifies :restart, resources("service[solr]"), :delayed
  end
