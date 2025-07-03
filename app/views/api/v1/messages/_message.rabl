attributes :id, :content, :created_at

node(:sender_id) { |m| m.sender.id }
node(:sender_name) { |m| m.sender.name }

node(:receiver_id) { |m| m.receiver.id }
node(:receiver_name) { |m| m.receiver.name }

child :project do
  attributes :id, :title
end
