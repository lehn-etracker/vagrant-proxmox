module VagrantPlugins
  module Proxmox
    module Action
      # set env[:result] to :is_created
      class IsCreated < ProxmoxAction
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info 'IsCreated: validating VM is created'
          env[:result] = env[:machine].state.id != :not_created
          if env[:result]
            env[:ui].warn 'Machine already exist'
          else
            env[:ui].warn 'Machine has to be created'
          end
          next_action env
        end
      end
    end
  end
end
