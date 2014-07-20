# Amahi Home Server
# Copyright (C) 2007-2013 Amahi
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License v3
# (29 June 2007), as published in the COPYING file.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# file COPYING for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Amahi
# team at http://www.amahi.org/ under "Contact Us."
require 'fileutils'
class DiskPoolShare < ActiveRecord::Base
	belongs_to :share

	def toggle_pooling!
		self.pooling = !self.pooling
		self.save!
		Pooling::Configuration.save_conf_file(DiskPoolPartition.all, DiskPoolShare.in_disk_pool)
	end

	def update_extra_copies(value)
		self.extra_copies =  value
		self.save!
		Pooling::Configuration.save_conf_file(DiskPoolPartition.all, DiskPoolShare.in_disk_pool)
	end

	def self.in_disk_pool
		share_ids = DiskPoolShare.where("extra_copies>0").map{|pool| pool.share_id}
		shares = []
		share_ids.each do |share_id|
			share = Share.where(:id=>share_id).first
			if share
				shares << share
			else
				DiskPoolShare.where(:share_id=>share_id).first.destroy!
			end
		end
		shares
	end
end
