module VagrantPlugins
	module Proxmox
		module Action

			# This action stores the ssh information in env[:machine_ssh_info]
			class ReadSSHInfo < ProxmoxAction

				def initialize app, env
					@app = app
					@logger = Log4r::Logger.new 'vagrant_proxmox::action::read_ssh_info'
				end

				def call env
					# here, we have to determine how to connect to new vm
					env[:ui].info I18n.t('vagrant_proxmox.read_ssh_info')
					env[:machine_ssh_info] = get_machine_ip_address(env).try do |ip_address|
						ssh_port = env[:machine].config.ssh.guest_port
						env[:ui].detail "Using #{ip_address}:#{ssh_port} to connect to VM"
						{host: ip_address, port: ssh_port}
					end
					next_action env
				end

			end

		end
	end
end
