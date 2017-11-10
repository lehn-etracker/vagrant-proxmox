module VagrantPlugins
  module Proxmox
    module Action
      # This action modifies the configuration of a cloned vm
      # Basically it creates a user network interface with hostfwd for the provisioning
      # and an interface for every public or private interface defined in the Vagrantfile
      class ConfigClone < ProxmoxAction
        def initialize(app, _env)
          @app = app
          @logger = Log4r::Logger.new 'vagrant_proxmox::action::config_clone'
          @node_ip = nil
          @guest_port = nil
        end

        def call(env)
          env[:ui].info I18n.t('vagrant_proxmox.configuring_vm')
          config = env[:machine].provider_config
          node = env[:proxmox_selected_node]
          vm_id = nil

          begin
            vm_id = env[:machine].id.split('/').last
            @node_ip = connection(env).get_node_ip(node, 'vmbr0') if config.vm_type == :qemu
            @guest_port = (22_000 + vm_id.to_i).to_s
          rescue StandardError => e
            raise VagrantPlugins::Proxmox::Errors::VMConfigError,
                  error_msg: 'ConfigClone error',
                  proxmox_exit_status: e.message
          end

          begin
            template_config = connection(env).get_vm_config node: node, vm_id: vm_id, vm_type: config.vm_type
            env[:ui].info "cloning vm with template_config: #{template_config.inspect}"
            params = create_params_qemu(config, env, vm_id, template_config)
            env[:ui].detail "cloning vm with params: #{params.inspect}"
            exit_status = connection(env).config_clone node: node, vm_type: config.vm_type, params: params
            exit_status == 'OK' ? exit_status : raise(VagrantPlugins::Proxmox::Errors::ProxmoxTaskFailed, proxmox_exit_status: exit_status)
          rescue StandardError => e
            raise VagrantPlugins::Proxmox::Errors::VMConfigError,
                  error_msg: "CloneConfig error, exit_status=#{exit_status.inspect}: #{e.message}",
                  proxmox_exit_status: e.backtrace.inspect
          end

          env[:ui].info I18n.t('vagrant_proxmox.done')
          next_action env
        end

        private

        def create_params_qemu(provider_config, env, vm_id, template_config)
          env[:ui].info 'CloneConfig create_params_qemu: called'
          vm_config = env[:machine].config.vm
          params = {
            vmid: vm_id,
            description: "#{provider_config.vm_name_prefix}#{env[:machine].name}"
          }
          # delete existing network interfaces from template
          to_delete = template_config.keys.select { |key| key.to_s.match(/^net/) }
          params[:delete] = to_delete.join(',') unless to_delete.empty?
          # net0 is the provisioning network, derived from forwarded_port
          net_num = 0
          hostname = vm_config.hostname || env[:machine].name
          netdev0 = [
            'type=user',
            'id=net0',
            "hostname=#{hostname}",
            "hostfwd=tcp:#{@node_ip}:#{@guest_port}-:22",	# selected_node's primary ip and port (22000 + vm_id)
          ]
          device0 = [
            # TODO: we need a special config option to define driver for forwarded_port to virtio-net
            'virtio-net',
            'netdev=net0',
            'bus=pci.0',
            'addr=0x12',	# starting point for network interfaces
            'id=net0',
            'bootindex=299'
          ]
          params[:args] = '-netdev ' + netdev0.join(',') + ' -device ' + device0.join(',')
          # params[:args] = '-netdev ' + netdev0.join(',')
          # params[:args] = '-no-reboot'
          # now add a network device for every public_network or private_network
          # ip addresses are ignored here, as we can't configure anything inside the qemu vm.
          # at least we can set the predefined mac address and a bridge
          net_num += 1
          vm_config.networks.each do |type, options|
            next unless type =~ /^p.*_network$/
            nic = provider_config.qemu_nic_model
            nic += "=#{options[:macaddress]}" if options[:macaddress]
            nic += ",bridge=#{options[:bridge]}" if options[:bridge]
            net = 'net' + net_num.to_s
            params[net] = nic
            net_num += 1
          end

          env[:ui].detail 'CloneConfig create_params_qemu: is setting more individual options'
          # some more individual settings
          params[:ide2] = "#{provider_config.qemu_iso},media=cdrom" if provider_config.qemu_iso
          params[:sockets] = provider_config.qemu_sockets.to_s.to_i if provider_config.qemu_sockets
          params[:cores] = provider_config.qemu_cores.to_s.to_i if provider_config.qemu_cores
          if provider_config.vm_memory &&
             template_config[:balloon].nil? == false &&
             provider_config.vm_memory < template_config[:balloon]
            #
            params[:balloon] = provider_config.vm_memory.to_s.to_i
          end
          params[:memory] = provider_config.vm_memory.to_s.to_i if provider_config.vm_memory
          env[:ui].detail 'CloneConfig create_params_qemu: finished'
          params
        end
      end
    end
  end
end
