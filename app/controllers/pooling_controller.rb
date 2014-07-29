class PoolingController < ApplicationController
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
		selection
	end

	def update_extra_copies
		copies = params[:extra_copies]
		share = Share.find(params[:id])
		if copies == "max"
			share.disk_pool_copies = 999
		else
			share.disk_pool_copies = copies.to_i + 1
		end
		share.save && generate_gh_config
		selection
		render :partial => 'pooling/disk_pool_share', :locals => { :share => share }
	end

	def toggle_share_pooling
		share = Share.find(params[:id])
		if share.disk_pool_copies > 0
			share.disk_pool_copies = 0
		else
			share.disk_pool_copies = 1
		end
		share.save && generate_gh_config
		selection
		render :partial => 'pooling/disk_pool_share', :locals => { :share => share }
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

	def run_fsck
		c = Command.new
		c.submit("greyhole --fsck")
		c.execute
		render :json => {:status=>:ok}
	end

	private

	def selection
		@partition_count = DiskPoolPartition.count
		return unless @partition_count > 1
		@selection = [["-", 0]]
		max = @partition_count - 1
		1.upto(max) do |i|
			@selection += [["#{i}", i]]
		end
		# Last choice is for all drives, present and future! FIXME - put it in a constant/symbol
		@selection += [["Always Max", "max"]]
	end

	def generate_gh_config
		Pooling::Configuration.save_conf_file(DiskPoolPartition.all, Share.where("disk_pool_copies > 0"))
	end

#	def settings
#		# do the settings page here
#	end

#	def advanced
#		# do the advanced settings page here
#	end
end
