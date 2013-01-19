class GraphController < ApplicationController

  def index
  	@neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")

  	johnathan = @neo.create_node("name" => 'Johnathan')
	mark = @neo.create_node("name" => 'Mark')
	phil = @neo.create_node("name" => 'Phil')
	mary = @neo.create_node("name" => 'Mary')
	luke = @neo.create_node("name" => 'Luke')
	@neo.create_relationship("friends", johnathan, mark)
	@neo.create_relationship("friends", mark, johnathan)
	@neo.create_relationship("friends", mark, mary)
	@neo.create_relationship("friends", mary, mark)
	@neo.create_relationship("friends", mark, phil)
	@neo.create_relationship("friends", phil, mark)
	@neo.create_relationship("friends", mary, phil)
	@neo.create_relationship("friends", phil, mary)
	@neo.create_relationship("friends", phil, luke)
	@neo.create_relationship("friends", luke, phil)
	s = @neo.traverse(johnathan,
	                "nodes", 
	                {"order" => "breadth first", 
	                 "uniqueness" => "node global", 
	                 "relationships" => {"type"=> "friends", 
	                                     "direction" => "in"}, 
	                 "return filter" => {"language" => "javascript",
	                                     "body" => "position.length() == 2;"},
	                 "depth" => 2}).map{|n| n["data"]["name"]}.join(', ')

	render :text => "Johnathan should become friends with #{s}" and return

=begin
	def create_person(name)
	  @neo.create_node("name" => name)
	end

	def make_mutual_friends(node1, node2)
	  @neo.create_relationship("friends", node1, node2)
	  @neo.create_relationship("friends", node2, node1)
	end

	def suggestions_for(node)
	  @neo.traverse(node,
	                "nodes", 
	                {"order" => "breadth first", 
	                 "uniqueness" => "node global", 
	                 "relationships" => {"type"=> "friends", 
	                                     "direction" => "in"}, 
	                 "return filter" => {"language" => "javascript",
	                                     "body" => "position.length() == 2;"},
	                 "depth" => 2}).map{|n| n["data"]["name"]}.join(', ')
	end

	johnathan = create_person('Johnathan')
	mark      = create_person('Mark')
	phil      = create_person('Phil')
	mary      = create_person('Mary')
	luke      = create_person('Luke')

	make_mutual_friends(johnathan, mark)
	make_mutual_friends(mark, mary)
	make_mutual_friends(mark, phil)
	make_mutual_friends(phil, mary)
	make_mutual_friends(phil, luke)

	puts "Johnathan should become friends with #{suggestions_for(johnathan)}"

	# RESULT
	# Johnathan should become friends with Mary, Phil
=end

  end
end
