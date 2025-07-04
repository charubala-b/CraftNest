collection @contracts
attributes :id, :status, :created_at, :updated_at

child(:project) { attributes :id, :title, :budget }

child(:freelancer) { attributes :id, :name, :email } if current_user.client?
child(:client) { attributes :id, :name, :email } if current_user.freelancer?
