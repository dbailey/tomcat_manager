# -*- coding: utf-8 -*-
# © 2012 Dakota Bailey
class TomcatManager
	@apps = nil

	def initialize(base_url, user, pass, timeout = nil, open_timeout = nil)
		@base_url = base_url
		@user = user
		@pass = pass
    @timeout = timeout
    @open_timeout = open_timeout
	end

  def undeploy(ctx_path)
    params = {"path" => ctx_path}
    results = execute("undeploy", {:headers => {:params => params}})
    if !/^OK.*/.match results
      puts "Unknown error: \n" + results
      exit 1
    end
    return results
  end

	def deploy(ctx_path, war_path)
		params = {"path" => ctx_path,
      "war" => war_path}
		results = execute("deploy", {:headers => {:params => params}})
 		if !/^OK.*/.match results
			puts "Unknown error: \n" + results
			exit 1
		end
		return results
	end

	def list()
		if @apps == nil
			@apps = {}
			apps_raw = execute("list")
			lines = apps_raw.split "\n"
			if !/^OK.*/.match lines[0]
				die "Unknown error: \n" + apps_raw
			end
			lines.slice(1, lines.length).each { |line|
				foo = /^\/(.*):(.*):(.*):(.*)$/
				data = foo.match line
				name = data[4].chomp
				ctx = data[1]
				status = data[2]
				foo = data[3]
				@apps[name] = {:name => name, :ctx => ctx, :status => status, :foo => foo}
			}
		end
		return @apps
	end

	def installed?(name)
		self.list[name]
	end

	def execute(cmd, options = {})
		url = @base_url + '/' + cmd
		opts = options.merge({:user => @user, :password => @pass, :timeout => @timeout, :open_timeout => @open_timeout})
		resource = RestClient::Resource.new url, opts
		resource.get
	end
end
