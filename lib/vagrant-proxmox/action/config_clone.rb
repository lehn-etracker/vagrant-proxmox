module VagrantPlugins
	module Proxmox
		module Action
			# This action modifies the configuration of a cloned vm
			# It applies only a subset of the whole configuration, excluding storage
			# and network options, which are inherited from the base template.
			class ConfigClone < ProxmoxAction

				def initialize app, env
					@app = app
					@logger = Log4r::Logger.new 'vagrant_proxmox::action::config_clone'
				end

				def call env
					env[:ui].info I18n.t('vagrant_proxmox.configuring_vm')
					config = env[:machine].provider_config
					node = env[:proxmox_selected_node]
					vm_id = env[:machine].id.split("/").last

					params = create_params_qemu(config, env, vm_id)
					begin
						exit_status = connection(env).config_clone node: node, vm_type: config.vm_type, params: params
						exit_status == 'OK' ? exit_status : raise(VagrantPlugins::Proxmox::Errors::ProxmoxTaskFailed, proxmox_exit_status: exit_status)
					rescue StandardError => e
						raise VagrantPlugins::Proxmox::Errors::VMConfigError, error_msg: e.message
					end

					next_action env
				end

				private
				def create_params_qemu(config, env, vm_id)
					desc = if config.use_plain_description
						config.description
					else
						"#{config.vm_name_prefix}#{env[:machine].name}:#{config.description}"
					end
					params = {
						vmid: vm_id,
						name: env[:machine].config.vm.hostname || env[:machine].name.to_s,
						sockets: config.qemu_sockets,
						cores: config.qemu_cores,
						memory: config.vm_memory,
						agent: get_rest_boolean(config.qemu_agent),
						description: desc
					}
					if config.qemu_iso
						params[:ide2] = "#{config.qemu_iso},media=cdrom"
					end
					params
				end

			end
		end
	end
end
