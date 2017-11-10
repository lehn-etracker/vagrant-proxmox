module VagrantPlugins
  module Proxmox
    module Action
      # set env[:result] to :stopped
      class IsStopped < ProxmoxAction
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info 'IsStopped: validating VM is stopped'
          env[:result] = env[:machine].state.id == :stopped
          if env[:result]
            env[:ui].warn 'Machine already stopped'
          else
            env[:ui].warn 'Machine has to be stopped'
          end
          next_action env
        end
      end
    end
  end
end
