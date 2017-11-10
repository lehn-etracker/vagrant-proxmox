module VagrantPlugins
  module Proxmox
    module Action
      # This action reads the state of a Proxmox virtual machine and stores it
      # in env[:machine_state_id].
      class ReadState < ProxmoxAction
        def initialize(app, _env)
          @app = app
          @logger = Log4r::Logger.new 'vagrant_proxmox::action::read_state'
        end

        def call(env)
          env[:ui].info 'ReadState: gathering current VM state'
          env[:machine_state_id] =
            if env[:machine].id
              node, vm_id = env[:machine].id.split '/'
              s = env[:proxmox_connection].get_vm_state vm_id
              env[:ui].detail "ReadState: VM (#{vm_id}@#{node}) is #{s}"
              s
            else
              env[:ui].detail 'ReadState: VM is not_created'
              :not_created
            end
          next_action env
        rescue => e
          raise Errors::CommunicationError,
                error_msg: "ReadState: #{e.message}"
        end
      end
    end
  end
end
