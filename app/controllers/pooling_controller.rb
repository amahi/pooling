class PoolingController < ApplicationController
	before_filter :admin_required

	DP_MIN_FREE_DEFAULT = 10
	DP_MIN_FREE_ROOT = 20
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
		selection
	end
	def update_extra_copies
		share_id = params[:id]
		copies = params[:extra_copies]
		share = Share.find(share_id)
		pool = DiskPoolShare.where(:share_id=>share.id).first
		pool.update_extra_copies(copies)
		selection
		render :partial => 'pooling/disk_pool_share', :locals => { :share => share , :pool => pool }
	end

	def toggle_share_pooling
		share_id = params[:id]
		share = Share.find(share_id)
		pool = DiskPoolShare.where(:share_id=>share.id).first
		if pool
			pool.toggle_pooling!
		else
			pool = DiskPoolShare.new
			pool.share = share
			pool.save!
			pool.toggle_pooling!
		end
		selection
		render :partial => 'pooling/disk_pool_share', :locals => { :share => share , :pool => pool }
	end

	def toggle_disk_pool_partition
		path = params[:path]
		status = DiskPoolPartition.toggle_disk_pool_partition!(path)
		if !status
			render :partial => 'pooling/partition_checkbox', :locals => { :checked => false, :path => path }
		else
			render :partial => 'pooling/partition_checkbox', :locals => { :checked => true, :path => path }
		end
	end
	private

	def selection
		@partition_count = DiskPoolPartition.count
		if @partition_count > 1
			@selection = [["-",1]]
			max = @partition_count - 1
			1.upto(max) do |i|
				@selection += [["#{i}",i+1]]
			end
			# Last choice is for all drives, present and future! FIXME - put it in a constant/symbol
			@selection += [["Always Max", 999]]
		end
	end

#	def settings
#		# do the settings page here
#	end

#	def advanced
#		# do the advanced settings page here
#	end
end
