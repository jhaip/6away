class GraphController < ApplicationController

  def index
  	@me = @neo.execute_query("START me=node:node_auto_index(athena='jhaip') RETURN me.name;")
  	puts @me
=begin
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
=end



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

  def create
  	@neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
  	me = @neo.create_node("athena" => "jhaip","name"=>"Jacob Haip","course"=>6,"year"=>2,"living_group"=>"Pi Lambda Phi","likes"=>["art","tech"])
  	user1 = @neo.create_node("athena" => "user1","name"=>"User One","course"=>2,"year"=>1,"living_group"=>"Next","likes"=>["art","tech"])
  	user2 = @neo.create_node("athena" => "user2","name"=>"User Two","course"=>2,"year"=>1,"living_group"=>"Next","likes"=>["art","tech"])
  	user3 = @neo.create_node("athena" => "user3","name"=>"User Three","course"=>2,"year"=>1,"living_group"=>"Next","likes"=>["art","tech"])
  	@neo.create_relationship("lives_with",me,user1)
  	@neo.create_relationship("lives_with",me,user2)
  	@neo.create_relationship("hangs_with",me,user2)
  	@neo.create_relationship("hangs_with",me,user3)
  	@neo.create_relationship("urop",me,user3)

  end

  def datapull
  	respond_to do |format|
      format.html { render :text => "Don't do this." }
      format.json { render :partial => "graph/datapull" }
    end
  end
end
