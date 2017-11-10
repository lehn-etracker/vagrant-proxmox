module VagrantPlugins
  module Proxmox
    module Action
      # This action reads the state of a Proxmox virtual machine and stores it
      # in env[:machine_state_id].
      class SelectNode < ProxmoxAction
        def initialize(app, _env)
          @app = app
          @logger = Log4r::Logger.new 'vagrant_proxmox::action::select_node'
        end

        def call(env)
          env[:ui].info 'SelectNode will try to select node to provision VM'
          if env[:machine].provider_config.selected_node != Config::UNSET_VALUE
            if env[:proxmox_nodes].include?(env[:machine].provider_config.selected_node)
              env[:proxmox_selected_node] = env[:machine].provider_config.selected_node
            else
              raise Errors::InvalidNodeError, node: env[:machine].provider_config.selected_node
            end
          else
            env[:proxmox_selected_node] = env[:proxmox_nodes].sample
          end
          env[:ui].detail "SelectNode: selected #{env[:proxmox_selected_node]}"
          next_action env
        end
      end
    end
  end
end
