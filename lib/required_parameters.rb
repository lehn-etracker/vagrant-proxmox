module VagrantPlugins::Proxmox
  module RequiredParameters
    def required(keyword)
      raise ArgumentError, "missing keyword: #{keyword}", caller
    end
  end
end
