class DiskPoolPartition < ActiveRecord::Base
	attr_accessible :minimum_free, :path

	DP_MIN_FREE_DEFAULT = 10
	DP_MIN_FREE_ROOT = 20

	after_save	:generate_config
	after_create	:generate_config
	after_destroy	:generate_config

	class << self

		def enabled?(path)
			p = self.find_by_path(path)
			! p.nil?
		end

		def toggle_disk_pool_partition!(path)
			part = self.find_by_path(path)
			# if it was enabled - disable it by deleting it
			return false if part && part.destroy
			# if the path is not really a partition or a mountpoint - ignore it and never enable it!
			if PartitionUtils.new.info.select{|p| p[:path] == path}.empty? or not Pathname.new(path).mountpoint?
				return false
			end
			min_free = path == '/' ? DP_MIN_FREE_ROOT : DP_MIN_FREE_DEFAULT
			self.create(:path => path, :minimum_free => min_free)
			true
		end
	end


	protected

	def generate_config
		Pooling::Configuration.save_conf_file(DiskPoolPartition.all, Share.where("disk_pool_copies > 0"))
	end
end
