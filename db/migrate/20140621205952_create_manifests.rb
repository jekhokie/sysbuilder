class CreateManifests < ActiveRecord::Migration
  def change
    create_table :manifests do |t|
      t.text   :configuration, limit: nil
      t.string :name

      t.timestamps
    end
  end
end
