module VagrantPlugins
  module Proxmox
    module Action
      # This class provdes helper functions.
      class ProxmoxAction
        protected

        def next_action(env)
          @app.call env
        end

        def get_machine_ip_address(env)
          config = env[:machine].provider_config
          if config.vm_type == :qemu
            ips = env[:machine].config.vm.networks.select {
              |type, iface| type == :forwarded_port and iface[:host_ip] != "127.0.0.1"
            }
            return ips.first[1][:host_ip] if not ips.empty?

            node = env[:proxmox_selected_node]
            vm_id = env[:machine].id.split("/").last

            connection(env).qemu_agent_get_vm_ip(node, vm_id)
          else
            env[:machine].config.vm.networks.select \
              { |type, _| type == :public_network }.first[1][:ip] || nil
          end
        end

        def get_machine_interface_name(env)
          env[:machine].config.vm.networks.select \
            { |type, _| type == :public_network }.first[1][:interface] || nil
        end

        def get_machine_bridge_name(env)
          env[:machine].config.vm.networks.select \
            { |type, _| type == :public_network }.first[1][:bridge] || nil
        end

        def get_machine_gw_ip(env)
          env[:machine].config.vm.networks.select \
            { |type, _| type == :public_network }.first[1][:gw] || nil
        end

        def get_machine_macaddress(env)
          env[:machine].config.vm.networks.select \
            { |type, _| type == :public_network }.first[1][:macaddress] || nil
        end

        def connection(env)
          env[:proxmox_connection]
        end

        def get_rest_boolean(input_boolean)
          if input_boolean
            1
          else
            0
          end
        end

        # get lxc network config
        #
        # Format with right order:
        # name=<string>[,bridge=<bridge>][,firewall=<1|0>][,gw=<GatewayIPv4>]
        #   [,gw6=<GatewayIPv6>][,hwaddr=<XX:XX:XX:XX:XX:XX>]
        #   [,ip=<IPv4Format/CIDR>][,ip6=<IPv6Format/CIDR>][,mtu=<integer>]
        #   [,rate=<mbps>][,tag=<integer>][,trunks=<vlanid[;vlanid...]>]
        #   [,type=<veth>]
        def add_lxc_network_config(env, params)
          config = env[:machine].provider_config

          if config.use_network_defaults &&
             config.lxc_network_defaults.is_a?(Array)
            # define shortcuts to networks and network_defaults
            network_defaults = config.lxc_network_defaults
            networks = env[:machine].config.vm.networks
            # iterate through networks defined within vm and
            # apply defaults if needed
            networks.each_with_index do |_n, i|
              # merge settings with defaults
              next if networks[i].nil? || networks[i][0].nil?
              next if network_defaults[i].nil? || network_defaults[i][0].nil?
              next unless networks[i][0].to_sym == network_defaults[i][0].to_sym
              # merge network
              networks[i][1] = network_defaults[i][1].merge(networks[i][1])
              env[:ui].detail "Network merged #{networks[i].inspect}" if config
                                                                         .dry
            end
          end

          # ensure machine has public_network defined
          has_public_network = false
          # env[:machine].config.vm.networks got replaced by networks
          networks.each do |n|
            # skip forwarded_port
            if n.first == :forwarded_port
              env[:ui].detail I18n.t('vagrant_proxmox.network_setup_ignored',
                                     net_config: n) if config.dry
              next
            end
            # help user to find config errors, if no public_network is defined
            has_public_network = true if n.first == :public_network
            # c = network config hash
            c = n.last
            %i(net_id bridge).each do |e|
              unless c.include?(e)
                raise Errors::VMConfigError,
                      error_msg: "Network #{n} has no :#{e} element."
              end
              if c[e].nil?
                raise Errors::VMConfigError,
                      error_msg: "Network #{n} has empty :#{e} element."
              end
            end

            # use interface name detection
            auto_interface = get_lxc_interface_name(c)
            c[:interface] = auto_interface if auto_interface

            unless c.include?(:interface)
              raise Errors::VMConfigError,
                    error_msg: "Network #{n} has no :interface element."\
                               " Set it to 'eth0' or similar."
            end

            # configuration entry
            cfg = []
            # name=<string>
            cfg.push("name=#{c[:interface]}")
            # [,bridge=<bridge>]
            %w(bridge firewall gw gw6 hwaddr).each do |entry|
              e = entry.to_sym
              next if c[e].to_s.empty? # ignore element if empty
              cfg.push("#{entry}=#{c[e]}") if c.include?(e)
            end
            has_ip = false
            # IPv4 - primary ip protocol
            e = :ip
            if c[:type] == 'dhcp' || (c.include?(e) && c[e] == 'dhcp')
              cfg.push('ip=dhcp')
              has_ip = true
            else
              v = get_ip_cidr4(c)
              if v
                cfg.push("ip=#{v}")
                has_ip = true
              end
            end
            # IPv6 - additionally used ip protocol
            e = :ip6
            if c.include?(e) && c[e] == 'dhcp'
              cfg.push('ip6=dhcp')
              has_ip = true
            else
              v = get_ip_cidr6(c)
              if v
                cfg.push("ip6=#{v}")
                has_ip = true
              end
            end

            if has_ip == false
              raise Errors::VMConfigError,
                    error_msg: "Network #{n} has no :ip or :ip6 element."\
                               ' You need to set an IP-Address'
            end
            # other options
            %w(mtu rate tag trunks).each do |entry|
              e = entry.to_sym
              next if c[e].to_s.empty? # ignore element if empty
              cfg.push("#{entry}=#{c[e]}") if c.include?(e)
            end
            # static interface type, similar in all cases
            cfg.push('type=veth')
            # give user feedback about network used setup
            env[:ui].detail I18n.t('vagrant_proxmox.network_setup_info',
                                   net_id: c[:net_id].to_s,
                                   net_config: cfg.join(','))
            params[c[:net_id].to_s] = cfg.join(',')
          end
          if has_public_network == false
            raise Errors::VMConfigError,
                  error_msg: 'Machine has no public_network. vagrant-proxmox'\
                             ' won\'t be able to connect to it. Please edit '\
                             ' your config.'
          end
        end

        # Get CIDR notation for IPv4 address
        # @param c network configuration part of \
        #          env[:machine].config.vm.networks
        # @param type type of ipaddress ip=IPv4, ip6=IPV6
        #
        # @return [String or Boolean]
        def get_ip_cidr(c, type)
          unless c.include?(:id)
            raise Errors::InternalPluginError, error_msg: \
              "Invalid network configuration part supplied: #{c}"
          end

          if type == 'ip'
            get_ip_cidr4(c)
          elsif type == 'ip6'
            get_ip_cidr6(c)
          else
            raise Errors::InvalidCidrTypeError, error_msg: type.to_s
          end
        end

        # Get CIDR notation for IPv4 address
        # @param c network configuration part of \
        #          env[:machine].config.vm.networks
        #
        # @return [String, Boolean]
        def get_ip_cidr4(c)
          return false unless c.include?(:ip)
          return false unless c.include?(:ip_cidr)
          begin
            return false unless IPAddr.new(c[:ip])
          rescue IPAddr::Error
            raise Errors::VMConfigError,
                  error_msg: "Invalid IP-Address supplied: #{c[:ip]}"
          end
          "#{c[:ip]}/#{c[:ip_cidr]}"
        end

        # Get CIDR notation for IPv6 address
        # @param c network configuration part of \
        #          env[:machine].config.vm.networks
        #
        # @return [String, Boolean]
        def get_ip_cidr6(c)
          return false unless c.include?(:ip6)
          return false unless c.include?(:ip6_cidr)
          begin
            return false unless IPAddr.new(c[:ip6])
          rescue IPAddr::Error
            raise Errors::VMConfigError,
                  error_msg: "Invalid IP-Address supplied: #{c[:ip6]}"
          end
          "#{c[:ip6]}/#{c[:ip6_cidr]}"
        end

        # Detect interface name from net_id
        # @param c network configuration part of \
        #          env[:machine].config.vm.networks
        #
        # @return [String or nil]
        def get_lxc_interface_name(c)
          # detect interface name
          return nil unless c.include?(:net_id)
          unless c.include?(:interface) == true
            netif_id = c[:net_id][/^net(\d+)$/, 1]
            # return nil if detection failed
            return nil if netif_id == c[:net_id]
            "eth#{netif_id}"
          end
        end

        # Add LXC mount points to params
        # Reads params and combines all defined lxc_mount_points to params.
        #
        # Format with right order:
        # mp[n]: [volume=]<volume>,mp=<Path>[,acl=<1|0>][,backup=<1|0>]
        #        [,quota=<1|0>][,ro=<1|0>][,size=<DiskSize>]
        #
        def add_lxc_mount_points(env, config, params)
          config.lxc_mount_points.each do |mp, cfg|
            # merge with defaults
            c = config.lxc_mount_point_defaults.merge(cfg)
            # validate config
            unless mp =~ /^mp\d$/
              raise Errors::VMConfigError,
                    error_msg: "Invalid mount point #{mp} in config."
            end
            # check required options
            %i(volume mp backup size).each do |k|
              unless c.include?(k)
                raise Errors::VMConfigError,
                      error_msg: "MountPoint #{mp} must have a '#{k}' item"
              end
            end
            # combine volume:size into volume
            c[:volume] = if c[:size].is_a?(Integer) && c[:size] > 0
                           "#{c[:volume]}:#{c[:size]}"
                         else
                           c[:volume].to_s
                         end
            # translate booleans
            %i(acl backup quota replicate ro shared).each do |k|
              c[k] = get_rest_boolean(c[k]) unless c[k] == -1
            end
            # build config string
            cs = []
            %i(volume mp acl backup quota replicate ro shared).each do |k|
              cs.push("#{k}=#{c[k]}") unless c[k] == -1
            end
            # add size if it is zero
            cs.push("size=#{c[:size]}") if c[:size].zero?
            # put mount point back into params
            e = mp.to_sym
            params[e] = cs.join(',')
            env[:ui].detail("MountPoint #{mp}: #{params[e]}")
          end
        end
      end
    end
  end
end
