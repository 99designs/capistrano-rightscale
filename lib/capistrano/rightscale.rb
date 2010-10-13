require 'rightscale-api'

module Capistrano
	class Configuration
		module Tags

			# Associate a tag in a specific deployment with a role
			# Examples:
			#   tag "x99:role=app", :app, :deployment => 45678
			def tag(which, *args)
				@rightscale ||= RightScale::Client.new(fetch(:rightscale_account), fetch(:rightscale_username), fetch(:rightscale_password))
				@deployments ||= @rightscale.deployments
				@servers ||= @rightscale.servers

				logger.info "querying rightscale for deployment %s" % args[1][:deployment]
				deployment = @deployments.index.find { |d| d['href'] == rightscale_url("/deployments/%d" % args[1][:deployment]) }

				deployment['servers'].each do |server|
					if server['state'] == 'operational' && tags_for_server(server).include?(which)
						settings = @servers.settings(server['href'])
						logger.info "found server %s (%s) with tag %s" % [ settings['dns_name'], server['nickname'], which ]
						server(settings['dns_name'], *args)
					end
				end
			end

			def tags_for_server(server)
				instance_id = server["current_instance_href"].split('/').last
				tags = @rightscale.get(rightscale_url("/tags/search.js?resource_href=/ec2_instances/%d" % instance_id))
				tags.collect { |x| x["name"] }
			end

			def rightscale_url(path)
				"https://my.rightscale.com/api/acct/%d%s" % [ fetch(:rightscale_account), path ]
			end
		end

		include Tags
	end
end