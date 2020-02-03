module VagrantPlugins
  module Proxmox
    module Action
      # This action creates a new virtual machine on the Proxmox server and
      # stores its node and vm_id env[:machine].id
      class CreateVm < ProxmoxAction
        def initialize(app, _env)
          @app = app
          @logger = Log4r::Logger.new 'vagrant_proxmox::action::create_vm'
        end

        def call(env)
          env[:ui].info I18n.t('vagrant_proxmox.creating_vm')
          config = env[:machine].provider_config

          node = env[:proxmox_selected_node]
          vm_id = nil

          begin
            vm_id = connection(env).get_free_vm_id
            params = create_params_openvz(config, env, vm_id) if config.vm_type == :openvz
            params = create_params_lxc(config, env, vm_id) if config.vm_type == :lxc
            params = create_params_qemu(config, env, vm_id) if config.vm_type == :qemu
            if config.dry == true
              env[:ui].detail I18n.t('vagrant_proxmox.dry_run',
                                     action: 'create_vm',
                                     params: params)
              raise VagrantPlugins::Proxmox::Errors::VMCreateError,
                    proxmox_exit_status: 'Dry run enabled'
            end
            exit_status = connection(env).create_vm node: node, vm_type: config.vm_type, params: params
            exit_status == 'OK' ? exit_status : raise(VagrantPlugins::Proxmox::Errors::ProxmoxTaskFailed, proxmox_exit_status: exit_status)
          rescue StandardError => e
            raise VagrantPlugins::Proxmox::Errors::VMCreateError, proxmox_exit_status: "#{e.message} with params #{params}"
          end

          env[:machine].id = "#{node}/#{vm_id}"

          env[:ui].info I18n.t('vagrant_proxmox.done')
          next_action env
        end

        private

        def create_params_qemu(config, env, vm_id)
          network = "#{config.qemu_nic_model},bridge=#{config.qemu_bridge}"
          network = "#{config.qemu_nic_model}=#{get_machine_macaddress(env)},bridge=#{config.qemu_bridge}" if get_machine_macaddress(env)
          desc = if config.use_plain_description
                   config.description
                 else
                   "#{config.vm_name_prefix}#{env[:machine].name}:#{config.description}"
                 end
          {
            vmid: vm_id,
            name: env[:machine].config.vm.hostname || env[:machine].name.to_s,
            ostype: config.qemu_os,
            ide2: "#{config.qemu_iso},media=cdrom",
            sata0: "#{config.qemu_storage}:#{config.qemu_disk_size},format=#{config.qemu_disk_format},cache=#{config.qemu_cache}",
            sockets: config.qemu_sockets,
            cores: config.qemu_cores,
            memory: config.vm_memory,
            net0: network,
            description: desc
          }
        end

        def create_params_openvz(config, env, vm_id)
          desc = if config.use_plain_description
                   config.description
                 else
                   "#{config.vm_name_prefix}#{env[:machine].name}:#{config.description}"
                 end
          {
            vmid: vm_id,
            ostemplate: config.openvz_os_template,
            hostname: env[:machine].config.vm.hostname || env[:machine].name.to_s,
            password: 'vagrant',
            memory: config.vm_memory,
            description: desc
          }.tap do |params|
            params[:ip_address] = get_machine_ip_address(env) if get_machine_ip_address(env)
          end
        end

        def create_params_lxc(config, env, vm_id)
          desc = if config.use_plain_description
                   config.description
                 else
                   "#{config.vm_name_prefix}#{env[:machine].name}:#{config.description}"
                 end
          {
            vmid: vm_id,
            ostemplate: config.openvz_os_template,
            hostname: env[:machine].config.vm.hostname || env[:machine].name.to_s,
            password: 'vagrant',
            rootfs: "#{config.vm_storage}:#{config.vm_disk_size}",
            memory: config.vm_memory,
            description: desc,
            cmode: config.lxc_cmode.to_s,
            cpulimit: config.lxc_cpulimit,
            cpuunits: config.lxc_cpuunits,
            swap: config.lxc_swap,
            tty: config.lxc_tty,
            pool: config.pool
          }.tap do |params|
            params['ssh-public-keys'] = config.lxc_ssh_public_keys
            params[:nameserver] = config.lxc_nameserver.to_s\
                                    if config.lxc_nameserver
            params[:onboot] = get_rest_boolean(config.lxc_onboot)
            params[:protection] = get_rest_boolean(config.lxc_protection)
            params[:console] = get_rest_boolean(config.lxc_console)
            params[:cores] = config.lxc_cores if config.lxc_cores
            params[:bwlimit] = config.lxc_bwlimit if config.lxc_bwlimit
            params[:features] = config.lxc_features if config.lxc_features
            params[:force] = get_rest_boolean(config.lxc_force)
            params[:hookscript] = config.lxc_hookscript if config.lxc_hookscript
            params[:unprivileged] = get_rest_boolean(config.lxc_unprivileged)
            add_lxc_network_config(env, params)
            add_lxc_mount_points(env, config, params)
          end
        end
      end
    end
  end
end
