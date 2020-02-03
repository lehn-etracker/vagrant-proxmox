module VagrantPlugins
  module Proxmox
    # Define proxmox specific vagrant settings
    class Config < Vagrant.plugin('2', :config)
      # The Proxmox REST API endpoint
      #
      # @return [String]
      attr_accessor :endpoint

      # The Proxmox preferred cluster node
      #
      # @return [String]
      attr_accessor :selected_node

      # The Proxmox user name
      #
      # @return [String]
      attr_accessor :user_name

      # The Proxmox password
      #
      # @return [String]
      attr_accessor :password

      # The virtual machine type, e.g. :openvz or :qemu or :lxc
      #
      # @return [Symbol]
      attr_accessor :vm_type

      # The openvz os template to use for the virtual machine
      #
      # @return [String]
      attr_accessor :openvz_os_template

      # The openvz os template file to upload and use for the virtual machine
      #
      # @return [String]
      attr_accessor :openvz_template_file

      # Should the openvz os template be replaced (deleted before upload)?
      #
      # @return [Boolean]
      attr_accessor :replace_openvz_template_file

      # The id range to use for the virtual machines
      #
      # @return [Range]
      attr_accessor :vm_id_range

      # The prefix for the virtual machine name
      #
      # @return [String]
      attr_accessor :vm_name_prefix

      # Amount of RAM for the virtual machine in MB
      #
      # @return [Integer]
      attr_accessor :vm_memory

      # The vm disk size to use for the virtual machine, e.g. '30G'
      #
      # @return [String]
      attr_accessor :vm_disk_size

      # The vm storage to use for the virtual machine, e.g. 'local', 'raid',
      # 'cephstore'
      # defaults to 'raid' for backwards compatability
      #
      # @return [String]
      attr_accessor :vm_storage

      # The maximum timeout for a proxmox server task (in seconds)
      #
      # @return [Integer]
      attr_accessor :task_timeout

      # The interval between two proxmox task status retrievals (in seconds)
      #
      # @return [Integer, Proc]
      attr_accessor :task_status_check_interval

      # The maximum timeout for a ssh connection to a virtual machine
      # (in seconds)
      #
      # @return [Integer]
      attr_accessor :ssh_timeout

      # The interval between two ssh reachability status retrievals (in seconds)
      #
      # @return [Integer, Proc]
      attr_accessor :ssh_status_check_interval

      # The maximum timeout for a proxmox server task if it's an upload
      # (in seconds)
      #
      # @return [Integer]
      attr_accessor :imgcopy_timeout

      # Add the VM to the specified pool.
      #
      # @return [String]
      attr_accessor :pool

      # The qemu virtual machine operating system, e.g. :l26
      #
      # @return [Symbol]
      attr_accessor :qemu_os

      # The number of cores per socket
      #
      # @return [Integer]
      attr_accessor :qemu_cores

      # The number of CPU sockets
      #
      # @return [Integer]
      attr_accessor :qemu_sockets

      # The qemu template to clone for the virtual machine
      #
      # @return [String]
      attr_accessor :qemu_template

      # The qemu iso file to use for the virtual machine
      #
      # @return [String]
      attr_accessor :qemu_iso

      # The qemu iso file to upload and use for the virtual machine
      #
      # @return [String]
      attr_accessor :qemu_iso_file

      # Should the qemu iso file replaced (deleted before upload)?
      #
      # @return [Boolean]
      attr_accessor :replace_qemu_iso_file

      # The qemu disk size to use for the virtual machine, e.g. '30G'
      #
      # @return [String]
      attr_accessor :qemu_disk_size

      # The qemu storage to use for the virtual machine, e.g. 'local', 'raid',
      # 'cephstore'
      # defaults to 'raid' for backwards compatability
      #
      # @return [String]
      attr_accessor :qemu_storage

      # The qemu network interface card model, e.g. 'e1000', 'virtio'
      # defaults to 'e1000' for backwards compatability
      #
      # @return [String]
      attr_accessor :qemu_nic_model

      # The qemu network bridge, e.g. 'vmbr0'
      # defaults to 'vmbr0' for backwards compatability
      #
      # @return [String]
      attr_accessor :qemu_bridge

      # The qemu disk format, e.g. 'raw', 'qcow2'
      # defaults to 'qcow2' for backwards compatability
      #
      # @return [String]
      attr_accessor :qemu_disk_format

      # The qemu cache, e.g. '', 'writeback'
      # defaults to '' for backwards compatability
      #
      # @return [String]
      attr_accessor :qemu_cache

      # disable ssh port adjustments
      #
      # @return [Boolean]
      attr_accessor :disable_adjust_forwarded_port

      # LXC Limit of CPU usage.
      # NOTE: If the computer has 2 CPUs, it has a total of '2' CPU time.
      #       Value '0' indicates no CPU limit.
      #
      # @return [Integer]
      attr_accessor :lxc_cpulimit

      # LXC Cores
      #
      # @return [Integer]
      attr_accessor :lxc_cores

      # LXC CPU weight for a VM.
      # Argument is used in the kernel fair scheduler. The larger the number is,
      # the more CPU time this VM gets. Number is relative to the weights of all
      # the other running VMs.
      # NOTE: You can disable fair-scheduler configuration by setting this to 0.
      #
      # @return [Integer]
      attr_accessor :lxc_cpuunits

      # LXC mount points
      # Use volume as container mount point.
      #
      # @return [Hash]
      attr_accessor :lxc_mount_points

      # LXC onboot
      # Specifies whether a VM will be started during system bootup.
      #
      # @return [Boolean]
      attr_accessor :lxc_onboot

      # LXC OS type
      # This is used to setup configuration inside the container, and
      # corresponds to lxc setup scripts in
      # /usr/share/lxc/config/<ostype>.common.conf. Value 'unmanaged' can be
      # used to skip and OS specific setup.
      #
      # @return [Symbol]
      attr_accessor :lxc_ostype

      # LXC protection
      # Sets the protection flag of the container. This will prevent the CT or
      # CT's disk remove/update operation.
      #
      # @return [Boolean]
      attr_accessor :lxc_protection

      # LXC Swap
      # Amount of SWAP for the VM in MB.
      #
      # @return [Integer]
      attr_accessor :lxc_swap

      # LXC networks
      # Specifies network interfaces for the container.
      #
      # @return [Hash]
      attr_accessor :lxc_networks

      # LXC nameserver
      # Sets DNS server IP address for a container. Create will automatically
      # use the setting from the host if you neither set searchdomain nor
      # nameserver.
      #
      # @return [String]
      attr_accessor :lxc_nameserver

      # LXC console
      # Attach a console device (/dev/console) to the container.
      #
      # @return [Boolean]
      attr_accessor :lxc_console

      # LXC Console mode.
      # By default, the console command tries to open a connection to one of the
      # available tty devices. By setting cmode to 'console' it tries to attach
      # to /dev/console instead. If you set cmode to 'shell', it simply invokes
      # a shell inside the container (no login).
      #
      # @return [String]
      attr_accessor :lxc_cmode

      # LXC tty
      # Specify the number of tty available to the container.
      #
      # @return [Integer]
      attr_accessor :lxc_tty

      # LXC mount point defaults
      # Values are used to set defaults for unset options.
      #
      # Format with right order:
      # mp[n]: [volume=]<volume>,mp=<Path>[,acl=<1|0>][,backup=<1|0>]
      #        [,quota=<1|0>][,ro=<1|0>][,size=<DiskSize>]
      # @return [Hash]
      attr_accessor :lxc_mount_point_defaults

      # Use network defaults
      # If true, network definitions from :lxc_network_defaults will be merged.
      #
      # @return [Boolean]
      attr_accessor :use_network_defaults

      # Dry run
      # Allow vagrant-proxmox to generate action an only print that out.
      #
      # @return [Boolean]
      attr_accessor :dry

      # LXC network defaults
      # Specifies network interfaces defaults for the container.
      #
      # @return [Hash]
      attr_accessor :lxc_network_defaults

      # VM/CT description
      # Container description. Only used on the configuration web interface.
      #
      # @return [String]
      attr_accessor :description

      # Use plain description
      # disable vagrant_default description prefix
      #
      # @return [Boolean]
      attr_accessor :use_plain_description

      # LXC ssh-public-keys
      # Setup public SSH keys (one key per line, OpenSSH format).
      #
      # @return [String]
      attr_accessor :lxc_ssh_public_keys

      # LXC bwlimit
      # Override I/O bandwidth limit (in KiB/s).
      # restore limit from datacenter or storage config
      #
      # @return [Integer]
      attr_accessor :lxc_bwlimit

      # LXC features
      # Allow containers access to advanced features.
      # fuse, keyctl, mount, nesting
      #
      # @return [String]
      attr_accessor :lxc_features

      # LXC force
      # Allow to overwrite existing container.
      #
      # @return [Boolean]
      attr_accessor :lxc_force

      # LXC hookscript
      # Script that will be exectued during various steps in the containers
      # lifetime.
      #
      # @return [String]
      attr_accessor :lxc_hookscript

      # LXC unprivileged
      # Makes the container run as unprivileged user.
      # (Should not be modified manually.)
      #
      # @return [Boolean]
      attr_accessor :lxc_unprivileged

      def initialize
        @endpoint = UNSET_VALUE
        @selected_node = UNSET_VALUE
        @user_name = UNSET_VALUE
        @password = UNSET_VALUE
        @vm_type = UNSET_VALUE
        @openvz_os_template = UNSET_VALUE
        @openvz_template_file = UNSET_VALUE
        @replace_openvz_template_file = false
        @vm_id_range = 900..999
        @vm_name_prefix = 'vagrant_'
        @vm_memory = 512
        @vm_disk_size = '20G'
        @vm_storage = 'local'
        @task_timeout = 60
        @task_status_check_interval = 2
        @ssh_timeout = 60
        @ssh_status_check_interval = 5
        @imgcopy_timeout = 120
        @pool = UNSET_VALUE
        @qemu_os = UNSET_VALUE
        @qemu_cores = 1
        @qemu_sockets = 1
        @qemu_template = UNSET_VALUE
        @qemu_iso = UNSET_VALUE
        @qemu_iso_file = UNSET_VALUE
        @replace_qemu_iso_file = false
        @qemu_disk_size = UNSET_VALUE
        @qemu_storage = 'raid'
        @qemu_nic_model = 'e1000'
        @qemu_bridge = 'vmbr0'
        @qemu_disk_format = 'qcow2'
        @qemu_cache = 'none'
        @disable_adjust_forwarded_port = false
        @lxc_cpulimit = 0
        @lxc_cpuunits = 1024
        @lxc_mount_points = {}
        @lxc_onboot = false
        @lxc_ostype = UNSET_VALUE
        @lxc_protection = false
        @lxc_swap = 512
        @lxc_nameserver = UNSET_VALUE
        @lxc_console = true
        @lxc_cmode = 'tty'
        @lxc_tty = UNSET_VALUE
        @lxc_mount_point_defaults = { acl: false,
                                      backup: false,
                                      quota: false,
                                      ro: false,
                                      size: 8 }
        @lxc_network_defaults = UNSET_VALUE
        @use_network_defaults = false
        @dry = false
        @description = UNSET_VALUE
        @use_plain_description = false
        @lxc_ssh_public_keys = UNSET_VALUE
        @lxc_cores = UNSET_VALUE
        @lxc_bwlimit = UNSET_VALUE
        @lxc_features = UNSET_VALUE
        @lxc_force = UNSET_VALUE
        @lxc_hookscript = UNSET_VALUE
        @lxc_unprivileged = true
      end

      # This is the hook that is called to finalize the object before it is put into use.
      def finalize!
        @endpoint = nil if @endpoint == UNSET_VALUE
        @selected_node = nil if @endpoint == UNSET_VALUE
        @user_name = nil if @user_name == UNSET_VALUE
        @password = nil if @password == UNSET_VALUE
        @vm_type = nil if @vm_type == UNSET_VALUE
        @openvz_template_file = nil if @openvz_template_file == UNSET_VALUE
        @openvz_os_template = "local:vztmpl/#{File.basename @openvz_template_file}" if @openvz_template_file
        @openvz_os_template = nil if @openvz_os_template == UNSET_VALUE
        @qemu_template = nil if @qemu_os == UNSET_VALUE
        @qemu_os = nil if @qemu_os == UNSET_VALUE
        @qemu_iso_file = nil if @qemu_iso_file == UNSET_VALUE
        @qemu_iso = "local:iso/#{File.basename @qemu_iso_file}" if @qemu_iso_file
        @qemu_iso = nil if @qemu_iso == UNSET_VALUE
        @qemu_disk_size = nil if @qemu_disk_size == UNSET_VALUE
        @qemu_disk_size = convert_disk_size_to_gigabyte @qemu_disk_size if @qemu_disk_size
        @vm_disk_size = convert_disk_size_to_gigabyte @vm_disk_size if @vm_disk_size
        @lxc_ostype = nil if @lxc_ostype == UNSET_VALUE
        @lxc_nameserver = nil if @lxc_nameserver == UNSET_VALUE
        @lxc_tty = 2 if @lxc_tty == UNSET_VALUE
        @pool = 'all' if @pool == UNSET_VALUE
        @description = '' if @description == UNSET_VALUE
        @lxc_ssh_public_keys = '' if @lxc_ssh_public_keys == UNSET_VALUE
        @lxc_cores = nil if @lxc_cores == UNSET_VALUE
        @lxc_cores = @lxc_cores.to_i unless @lxc_cores.nil?
        @lxc_bwlimit = nil if @lxc_bwlimit == UNSET_VALUE
        @lxc_bwlimit = @lxc_bwlimit.to_i unless @lxc_bwlimit.nil?
        @lxc_features = cleanup_lxc_features @lxc_features if @lxc_features
        @lxc_force = nil if @lxc_force == UNSET_VALUE
        @lxc_hookscript = nil if @lxc_hookscript == UNSET_VALUE
      end

      def validate(_machine)
        errors = []
        errors << I18n.t('vagrant_proxmox.errors.no_endpoint_specified') unless @endpoint
        errors << I18n.t('vagrant_proxmox.errors.no_user_name_specified') unless @user_name
        errors << I18n.t('vagrant_proxmox.errors.no_password_specified') unless @password
        errors << I18n.t('vagrant_proxmox.errors.no_vm_type_specified') unless @vm_type
        if @vm_type == :openvz
          errors << I18n.t('vagrant_proxmox.errors.no_openvz_os_template_or_openvz_template_file_specified_for_type_openvz') unless @openvz_os_template || @openvz_template_file
        end
        if @vm_type == :qemu
          if @qemu_template
          else
            errors << I18n.t('vagrant_proxmox.errors.no_qemu_os_specified_for_vm_type_qemu') unless @qemu_os
            errors << I18n.t('vagrant_proxmox.errors.no_qemu_iso_or_qemu_iso_file_specified_for_vm_type_qemu') unless @qemu_iso || @qemu_iso_file
            errors << I18n.t('vagrant_proxmox.errors.no_qemu_disk_size_specified_for_vm_type_qemu') unless @qemu_disk_size
          end
        end
        if @vm_type == :lxc
          errors << I18n.t('vagrant_proxmox.errors.lxc_no_valid_cmode') unless \
            %w[tty shell console].include?(@lxc_cmode)
          errors << I18n.t('vagrant_proxmox.errors.lxc_no_valid_tty') unless \
            @lxc_tty.is_a?(Integer)
            unless @lxc_cores.nil?
              unless 0 < @lxc_cores and @lxc_cores <= 128
                errors << I18n.t('vagrant_proxmox.errors.lxc_invalid_cores',
                                  value: @lxc_cores)
              end
            end
        end
        { 'Proxmox Provider' => errors }
      end

      private

      def convert_disk_size_to_gigabyte(disk_size)
        case disk_size[-1]
        when 'G'
          disk_size[0..-2]
        else
          disk_size
        end
      end

      def cleanup_lxc_features(lxc_features)
        clean_features = {}
        return nil if lxc_features.to_s.empty?
        return nil if lxc_features == UNSET_VALUE
        # parse feature string supplied
        lxc_features_h = lxc_features.split(',').map do |o|
          x = o.split('=')
          {x[0] => x[1]}
        end.inject(:merge)
        # filter invalid values
        %w[fuse keyctl nesting mount].each do |f|
          clean_features[f] = lxc_features_h[f] if lxc_features_h.include?(f)
        end
        # convert back to string
        clean_features.map {|k,v| "#{k}=#{v}" }.join(',')
      end
    end
  end
end
