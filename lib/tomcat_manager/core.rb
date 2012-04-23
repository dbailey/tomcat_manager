# -*- coding: utf-8 -*-
# © 2012 Dakota Bailey
class TomcatManager
	def initialize(base_url, user, pass, timeout = nil, open_timeout = nil)
		@base_url = base_url
		@user = user
		@pass = pass
    @timeout = timeout
    @open_timeout = open_timeout
	end

  def resources(type = nil)
    opts = {}
    if type != nil
      params = {"type" => type}
      opts[:headers] = {:params => params}
    end
    results = do_get("resources", opts)
    lines = results.split "\n"
    if !/^OK.*/.match lines[0]
      puts "Unknown error: \n" + results
      exit 1
    end
    info = {}
    rg = /^(.*):(.*)$/
    lines.slice(1, lines.length).each { |line|
      data = rg.match line
      name = data[1].strip
      value = data[2].strip
      info[name] = value
    }
    return info

    return results
  end

  def serverinfo()
    results = do_get("serverinfo")
    lines = results.split "\n"
    if !/^OK.*/.match lines[0]
      puts "Unknown error: \n" + results
      exit 1
    end
    info = {}
    rg = /^(.*):(.*)$/
    lines.slice(1, lines.length).each { |line|
      data = rg.match line
      name = data[1].strip
      value = data[2].strip
      info[name] = value
    }
    return info

    return results
  end

  def redeploy(ctx_path)
    params = {"path" => ctx_path}
    results = do_get("redeploy", {:headers => {:params => params}})
    if !/^OK.*/.match results
      puts "Unknown error: \n" + results
      exit 1
    end
    return results
  end

  def undeploy(ctx_path)
    params = {"path" => ctx_path}
    results = do_get("undeploy", {:headers => {:params => params}})
    if !/^OK.*/.match results
      puts "Unknown error: \n" + results
      exit 1
    end
    return results
  end

	def deploy(ctx_path, war_path)
		params = {"path" => ctx_path,
      "war" => war_path}
		results = do_get("deploy", {:headers => {:params => params}})
 		if !/^OK.*/.match results
			puts "Unknown error: \n" + results
			exit 1
		end
		return results
	end

	def remote_deploy(ctx_path, file)
		params = {"path" => ctx_path}
		results = do_put_with_file("deploy", file, {:headers => {:params => params}})
 		if !/^OK.*/.match results
			puts "Unknown error: \n" + results
			exit 1
		end
		return results
	end

	def list()
    apps_raw = do_get("list")
    lines = apps_raw.split "\n"
    if !/^OK.*/.match lines[0]
      die "Unknown error: \n" + apps_raw
    end
    apps = {}
    lines.slice(1, lines.length).each { |line|
      rg = /^\/(.*):(.*):(.*):(.*)$/
      data = rg.match line
      name = data[4].chomp
      ctx = data[1]
      status = data[2]
      sess_cnt = data[3]
      apps[name] = {:name => name, :ctx => ctx, :status => status, :sessions => sess_cnt}
    }
    return apps
	end

	def installed?(name)
		self.list[name]
	end

	def do_get(cmd, options = {})
		url = @base_url + '/' + cmd
		opts = options.merge({:user => @user, :password => @pass, :timeout => @timeout, :open_timeout => @open_timeout})
		resource = RestClient::Resource.new url, opts
		resource.get
	end

	def do_put_with_file(cmd, file, options = {})
		url = @base_url + '/' + cmd
		opts = options.merge({:user => @user, :password => @pass, :timeout => @timeout, :open_timeout => @open_timeout})
		resource = RestClient::Resource.new url, opts
		resource.put File.read(file)
	end
end
