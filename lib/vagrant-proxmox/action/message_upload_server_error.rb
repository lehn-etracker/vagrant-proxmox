module VagrantPlugins
  module Proxmox
    module Action
      class MessageUploadServerError < ProxmoxAction
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t('vagrant_proxmox.errors.server_upload_error')
          next_action env
         end
      end
    end
  end
end
