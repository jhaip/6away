class GraphController < ApplicationController

  def index
  	@neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
  	@one = @neo.execute_query("START n=node(*) WHERE n.athena ='jhaip' RETURN n.name, n.course, n.year, n.living_group, n.likes;")["data"][0]
  	@two = @neo.execute_query("START n=node(*) MATCH n-[r]->() WHERE n.athena ='jhaip' RETURN collect(type(r));")["data"][0]
  	@three = @neo.execute_query("START n=node(*) MATCH n<-[r]-() WHERE n.athena ='jhaip' RETURN collect(type(r));")["data"][0]

  	@name = @one[0]
  	@course = @one[1]
  	@year = @one[2]
  	@living_group = @one[3]
  	@likes = @one[4]
  	@out_relations = @two
  	@in_relations = @three

  	puts @name
  	puts @course
  	puts @year
  	puts @living_group
  	puts @likes
  	puts @out_relations
  	puts @in_relations
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

  	render :text => "done"

  end

  def datapull
  	@neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
  	@neo.execute_query("START n=node(*) MATCH n-[r]->() WHERE n.athena ='#{params[:name]}' RETURN n.name, collect(type(r));")["data"][0]
  	name = @neo[0]
  	@connections = @neo[1]
  	children = Array.new
  	@connections.each do |c|
  		t = {:name => c, :type => "category", :children => []}
  		children << t
  	end
  	ret = {:name => name, :type => "person", :children => children }
  	render :json => ret.to_json

=begin
  	respond_to do |format|
      format.html { render :text => "Don't do this." }
      format.json { render :partial => "graph/datapull" }
    end
=end
  end
end
