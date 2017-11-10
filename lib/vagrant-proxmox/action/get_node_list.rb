module VagrantPlugins
  module Proxmox
    module Action
      # This action gets a list of all the nodes e.g. ['node1', 'node2'] of
      # a Proxmox server cluster and stores it under env[:proxmox_nodes]
      class GetNodeList < ProxmoxAction
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info 'GetNodeList will query Proxmox-Cluster for its nodes'
          begin
                env[:proxmox_nodes] = env[:proxmox_connection].get_node_list
              rescue => e
                raise Errors::CommunicationError,
                      error_msg: "GetNodeList: #{e.message} #{e.backtrace.first}"
              end
          env[:ui].info 'GetNodeList found Proxmox-Nodes: '\
						"#{env[:proxmox_nodes].join(',')}"
          next_action env
        end
      end
    end
  end
end
