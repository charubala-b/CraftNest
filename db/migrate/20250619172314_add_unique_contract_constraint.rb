class AddUniqueContractConstraint < ActiveRecord::Migration[7.0]
  def change
    add_index :contracts, [:project_id, :client_id, :freelancer_id], unique: true, name: 'index_unique_contracts'
  end
end
