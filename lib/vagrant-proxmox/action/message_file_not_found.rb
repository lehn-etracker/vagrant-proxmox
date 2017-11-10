module VagrantPlugins
  module Proxmox
    module Action
      class MessageFileNotFound < ProxmoxAction
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          # TODO: add file name
          env[:ui].info I18n.t('vagrant_proxmox.errors.file_not_found')
          next_action env
         end
      end
    end
  end
end
