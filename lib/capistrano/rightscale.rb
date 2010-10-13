require 'rightscale-api'

module Capistrano
	class Configuration
		module Tags

			# Associate a tag in a specific deployment with a role
			# Examples:
			#   tag "x99:role=app", :app, :deployment => 45678
			def tag(which, *args)
				@rightscale ||= RightScale::Client.new(fetch(:rightscale_account), fetch(:rightscale_username), fetch(:rightscale_password))

				base_url = "https://my.rightscale.com/api/acct/%d" % fetch(:rightscale_account)
				deployment_url = base_url + "/deployments/%d" % args[1][:deployment]

				# find servers with the right tag
				tagged_servers = @rightscale.get(base_url + "/tags/search.js?resource_type=server&tags[]=%s" % which)
				tagged_servers.each {|server|

					if server['state'] == 'operational' && server['deployment_href'] == deployment_url
						settings = @rightscale.servers.settings(server['href'])
						pp settings['dns_name']
						pp server['tags']
						pp server['nickname']
						pp server['deployment_href']
						server(settings['dns_name'], *args)
					end
				}
			end
		end

		include Tags
	end
end