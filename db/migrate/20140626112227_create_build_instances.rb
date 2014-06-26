class CreateBuildInstances < ActiveRecord::Migration
  def change
    create_table :build_instances do |t|
      t.references :manifest
      t.string     :channel
      t.boolean    :active
      t.text       :status, limit: nil

      t.timestamps
    end
  end
end
