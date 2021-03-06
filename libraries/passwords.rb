class Chef
  # Public: This class provides helpers for retrieving passwords from encrypted
  # data bags
  class EncryptedPasswords
    attr_accessor :node, :bag

    def initialize(node, bag = "passwords")
      @node = node
      @bag = bag
    end

    # helper for passwords
    def find_password(key, user, default = nil)
      begin
        # first, let's check for an encrypted data bag and the given key
        passwords = Chef::EncryptedDataBagItem.load(@bag, key)
        # now, let's look for the user password
        password = passwords[user]
      rescue
        Chef::Log.info("Using non-encrypted password for #{user}, #{key}")
      end
      # password will be nil if no encrypted data bag was loaded
      # fall back to the attribute on this node
      password || default
    end

    # mysql root
    def root_password
      find_password "mysql", "root", node_server[:root_password]
    end

    # debian script user password
    def debian_password
      find_password(
        "system", node_server[:debian_username], node_server[:debian_password]
      )
    end

    # ?
    def old_passwords
      find_password "mysql", "old_passwords", node_server[:old_passwords]
    end

    # password for user responsbile for replicating in master/slave environment
    def replication_password
      find_password "mysql", "replication", node_server[:replication][:password]
    end

    # password for user responsbile for running xtrabackup
    def backup_password
      backup = node["percona"]["backup"]
      find_password "mysql", backup["username"], backup["password"]
    end

    private

    # helper
    def node_server
      @node[:percona][:server]
    end
  end
end
