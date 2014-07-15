class PoolingsController < ApplicationController
	before_filter :admin_required

	def index
		pl = PartitionUtils.new.info.to_a
		@partitions = pl.delete_if do |p|
			p[:bytes_free] < 200.megabytes and not DiskPoolPartition.find_by_path(p[:path])
		end
		dppl = DiskPoolPartition.all.to_a
		@broken_disk_pool_partitions = dppl.delete_if do |dpp|
			! @partitions.select{ |p| p[:path] == dpp.path }.empty?
		end
	end
	def shares
		@shares = Share.all
		@pooled_shares = []
		@shares.each do |share|
			if DiskPoolShare.where(:share_id=>share.id).first
				@pooled_shares << DiskPoolShare.where(:share_id=>share.id).first
			else
				@pooled_shares << nil
			end
		end
		@partition_count = DiskPoolPartition.count
		if @partition_count > 1
			@selection = [["-", 1]]
			max = @partition_count - 1
			1.upto(max) do |i|
				@selection += [["#{i}", i+1]]
			end
			# Last choice is for all drives, present and future! FIXME - put it in a constant/symbol
			@selection += [["Always Max", 999]]
		end
	end
	def update_extra_copies
	end

	def toggle_share_pooling
	end


#	def settings
#		# do the settings page here
#	end

#	def advanced
#		# do the advanced settings page here
#	end
end
