class GraphController < ApplicationController

  skip_before_filter :require_login

  def index
=begin
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
=end
	@name = "Jacob Haip"
	@course = 6
	@year = 2
	@living_group = "Pilam"
	@likes = ["art","tec"]
  end

  def profile
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
  	query = @neo.execute_query("START n=node(*) MATCH n-[r]->() WHERE n.athena ='#{params[:name]}' RETURN n.name, n.course, n.year, n.living_group, n.likes, collect(type(r));")["data"][0]
  	name = query[0]
  	course = query[1]
  	year = query[2]
  	living_group = query[3]
  	likes = query[4]
  	connections = query[5]
  	children = Array.new
  	connections.each do |c|
  		t = {:name => c, :type => "category", :children => Array.new }
  		children << t
  	end
  	ret = {:details => {:name => name, :course => course, :year => year, :living_group => living_group, :likes => likes},
           :graph   => {:name => name, :type => "person", :children => children }
          }
  	render :json => ret.to_json
  end

  def datapush
    a = "name: "+params[:name]+" year: "+params[:year]+" LG: "+params[:living_group]
    #a += " Art: "+params[:ch_art]+" Music"+params[:ck_music]+" Travel: "+params[:ck_travel]+" Alone "+params[:ck_alone]
    puts "-----------------------------------------"
    puts a
    puts "-----------------------------------------"
    redirect_to(:graph)
  end

  def userpull

    file = File.new(Rails.public_path+"/mit.txt")
    obj = file.read
    term = params[:term]

    i = 0
    a = Array.new
    JSON.parse(obj).each do |item|
      if item["label"].downcase.index(term) != nil
        a << item
        i += 1
        if i > 8
          break
        end
      end
    end
    render :json => a.to_json

  end

end
