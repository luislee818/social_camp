class AddDestroyedContentSummaryToChangelogs < ActiveRecord::Migration
  def change
    add_column :changelogs, :destroyed_content_summary, :string
  end
end
