module VagrantPlugins
  module Proxmox
    module Action
      class MessageAlreadyStopped < ProxmoxAction
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t('vagrant_proxmox.already_stopped')
          next_action env
        end
      end
    end
  end
end
