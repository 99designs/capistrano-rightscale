require 'rightscale-api'
require 'json'
require 'fileutils'

module Capistrano
  class Configuration
    module Tags

      def deployment(deployment)
        logger.info "querying rightscale for deployment %s" % deployment
        deployment = rightscale.deployments.index.find { |d| d['href'] == rightscale_url("/deployments/%d" % deployment) }
        servers = []
        deployment['servers'].each do |server|
          if server['state'] == 'operational'
            settings = rightscale.servers.settings(server['href'])
            servers.push << {
              'dns_name' => settings['dns_name'],
              'tags' => tags_for_server(server)
              }
          end
        end
        servers
      end

      # associate a tag in a specific deployment with a role
      # e.g:
      #   tag "x99:role=app", :app, :deployment => 45678
      def tag(which, *args)
        cache_file = '%s/.rightscale%d' % [ ENV['HOME'], args[1][:deployment] ]

        if File.exist?(cache_file) and ENV.fetch('RIGHTSCALE_CACHE', 'true') == 'true'
          logger.info("cache file found for deployment %d" % args[1][:deployment]);
          servers = JSON.parse(File.open(cache_file, "r").read)
        else
          servers = deployment(args[1][:deployment])
          File.open(cache_file, 'w') {|f| f.write(servers.to_json) }
        end

        servers.each do |server|
          server(server['dns_name'], *args) if server['tags'].include?(which)
        end
      end

      # query rightscale for tags for a running instance
      def tags_for_server(server)
        instance_id = server["current_instance_href"].split('/').last
        tags = rightscale.get(rightscale_url("/tags/search.js?resource_href=/ec2_instances/%d" % instance_id))
        tags.collect { |x| x["name"] }
      end

      # rightscale client
      def rightscale
         @rightscale ||= RightScale::Client.new(
           fetch(:rightscale_account), fetch(:rightscale_username), fetch(:rightscale_password))
      end

      def rightscale_url(path)
        "https://my.rightscale.com/api/acct/%d%s" % [ fetch(:rightscale_account), path ]
      end
    end

    include Tags
  end
end
