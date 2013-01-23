class GraphController < ApplicationController

  skip_before_filter :require_login, :except => [:datapush]

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
=end
    #if current_user == nil
    #  redirect_to( root_path, :notice => "Couldn't find current user") and return
    #end
    current_email = current_user.email
    @athena_name = current_email[/[^@]+/]

    @neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
    person = @neo.get_node_index("nodes", "name", @athena_name)
    if person == nil
      puts "person #{@athena_name} not found, redirecting to profile page to create them"
      redirect_to :profile
    else
      props = @neo.get_node_properties(person, ["course","year"])
      puts props
      if props["course"] == nil or props["course"] == nil
        puts "properties for #{@athena_name} found to be empty, redirecting to profile to fill them out"
        redirect_to :profile
      end
    end

  end

  def profile
  end

  def profile_push
    if current_user == nil
      redirect_to( root_path, :notice => "Couldn't find current user") and return
    end
    full_name = params[:name]
    year = params[:year]
    major = params[:major]
    living_group = params[:living_group]

    current_email = current_user.email
    athena_name = current_email[/[^@]+/]

    likes = Array.new

    if params[:ck_art]
      likes << "Art"
    end
    if params[:ck_music]
      likes << "Music"
    end
    if params[:ck_travel]
      likes << "Travel"
    end
    if params[:ck_alone]
      likes << "Time alone"
    end

    puts "Adding: "+full_name+", "+year+", "+major+", "+living_group+", "+athena_name
    puts "likes:"
    puts likes

    @neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")

    person = @neo.get_node_index("nodes", "name", athena_name)

    if person == nil
      puts "creating new person and adding properties"
      person = @neo.create_node
      @neo.add_node_to_index("nodes", "name", athena_name, person)
    end
    puts "person already exists, updating properties"
    @neo.set_node_properties(person, {"athena" => athena_name,
                                       "name"=>full_name,
                                       "course"=>major,
                                       "year"=>year,
                                       "living_group"=>living_group })
    if likes.length > 0
      puts "adding likes"
      @neo.set_node_properties(person, {"likes"=>likes})
    else
      puts "no likes found"
      @neo.remove_node_properties(person, "likes")
    end

    redirect_to(:graph)
  end

  def create
  	@neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")

    @neo.create_node_index("nodes")

  	me = @neo.create_node("athena" => "jhaip","name"=>"Jacob Haip","course"=>6,"year"=>2,"living_group"=>"Pi Lambda Phi","likes"=>["art","tech"])
  	user1 = @neo.create_node("athena" => "__user1","name"=>"User One","course"=>2,"year"=>1,"living_group"=>"Next","likes"=>["art","tech"])
  	user2 = @neo.create_node("athena" => "__user2","name"=>"User Two","course"=>2,"year"=>1,"living_group"=>"Next","likes"=>["art","tech"])
  	user3 = @neo.create_node("athena" => "__user3","name"=>"User Three","course"=>2,"year"=>1,"living_group"=>"Next","likes"=>["art","tech"])
  	@neo.create_relationship("lives_with",me,user1)
  	@neo.create_relationship("lives_with",me,user2)
  	@neo.create_relationship("hangs_with",me,user2)
  	@neo.create_relationship("hangs_with",me,user3)
  	@neo.create_relationship("urop",me,user3)
    @neo.add_node_to_index("nodes", "name", "jhaip", me)
    @neo.add_node_to_index("nodes", "name", "__user1", user1)
    @neo.add_node_to_index("nodes", "name", "__user2", user2)
    @neo.add_node_to_index("nodes", "name", "__user3", user3)

  	render :text => "database created"

  end

  def datapull
  	@neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
  	query = @neo.execute_query("START n=node(*) WHERE n.athena ='#{params[:name]}' RETURN n.name, n.course, n.year, n.living_group, n.likes;")["data"][0]
    query2 = @neo.execute_query("START n=node(*) MATCH n-[r]->() WHERE n.athena ='#{params[:name]}' RETURN collect(type(r));")["data"][0]
  	name = query[0]
  	course = query[1]
  	year = query[2]
  	living_group = query[3]
  	likes = query[4]
  	connections = query2[0]
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
