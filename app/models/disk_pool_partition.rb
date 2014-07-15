class DiskPoolPartition < ActiveRecord::Base
	attr_accessible :minimum_free, :path

	DP_MIN_FREE_DEFAULT = 10
	DP_MIN_FREE_ROOT = 20

	after_save	:regenerate_confguration
	after_create	:regenerate_confguration
	after_destroy	:regenerate_confguration

	def self.enabled?(path)
		p = self.find_by_path(path)
		! p.nil?
	end

	class << self
		def toggle_disk_pool_partition!(path)
			part = self.find_by_path(path)
			if part
				# was enabled - disable it by deleting it
				# FIXME - see http://bugs.amahi.org/issues/show/510
				part.destroy
				return false
			else
				# if the path is not really a partition or a mountpoint - ignore it and never enable it!
				if PartitionUtils.new.info.select{|p| p[:path] == path}.empty? or not Pathname.new(path).mountpoint?
					return false
				else
					min_free = path == '/' ? DP_MIN_FREE_ROOT : DP_MIN_FREE_DEFAULT
					self.create(:path => path, :minimum_free => min_free)
					return true
				end
			end
		end
	end


	protected

	def regenerate_confguration
		Poolings::Configuration.save_conf_file(DiskPoolPartition.all, DiskPoolShare.in_disk_pool)
	end
end
