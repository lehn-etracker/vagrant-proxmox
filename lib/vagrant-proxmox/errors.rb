module VagrantPlugins
  module Proxmox
    class ProxmoxTaskNotFinished < RuntimeError
    end

    module Errors
      class VagrantProxmoxError < Vagrant::Errors::VagrantError
        error_namespace 'vagrant_proxmox.errors'
      end

      class ProxmoxTaskFailed < VagrantProxmoxError
        error_key :proxmox_task_failed
      end

      class CommunicationError < VagrantProxmoxError
        error_key :communication_error
      end

      class Timeout < VagrantProxmoxError
        error_key :timeout
      end

      class NoVmIdAvailable < VagrantProxmoxError
        error_key :no_vm_id_available
      end

      class VMCreateError < VagrantProxmoxError
        error_key :vm_create_error
      end

      class VMCloneError < VagrantProxmoxError
        error_key :vm_clone_error
      end

      class NoTemplateAvailable < VagrantProxmoxError
        error_key :no_template_available
      end

      class VMConfigError < VagrantProxmoxError
        error_key :vm_configure_error
      end

      class VMDestroyError < VagrantProxmoxError
        error_key :vm_destroy_error
      end

      class VMStartError < VagrantProxmoxError
        error_key :vm_start_error
      end

      class VMStopError < VagrantProxmoxError
        error_key :vm_stop_error
      end

      class VMShutdownError < VagrantProxmoxError
        error_key :vm_shutdown_error
      end

      class RsyncError < VagrantProxmoxError
        error_key :rsync_error
      end

      class SSHError < VagrantProxmoxError
        error_key :ssh_error
      end

      class InvalidNodeError < VagrantProxmoxError
        error_key :invalid_node_error
      end

      # Error thrown on invalid CIDR Type value
      class InvalidCidrTypeError < VagrantProxmoxError
        error_key :invalid_cidr_type_error
      end

      # Internal Plugin Error (Bug)
      class InternalPluginError < VagrantProxmoxError
        error_key :internal_plugin_error
      end

      class ProxmoxActionError < VagrantProxmoxError
        error_key :proxmox_action_error
      end
    end
  end
end
