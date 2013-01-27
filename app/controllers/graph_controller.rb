class GraphController < ApplicationController

  skip_before_filter :require_login, :except => [:datapush]

  def index
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

    unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join

    puts "Adding: "+full_name+", "+year+", "+major+", "+living_group+", "+athena_name+", "+unique_id
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
                                       "living_group"=>living_group,
                                       "id"=>unique_id })
    if likes.length == 0
      likes = ["empty"]
    end
    @neo.set_node_properties(person, {"likes"=>likes})

    redirect_to(:graph)
  end

  def create
  	@neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")

    @neo.create_node_index("nodes")

    unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
  	me = @neo.create_node("athena" => "jhaip","id"=>unique_id,"name"=>"Jacob Haip","course"=>6,"year"=>2,"living_group"=>"Pi Lambda Phi","likes"=>["art","tech"])
    unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
  	user1 = @neo.create_node("athena" => "ssul","id"=>unique_id,"name"=>"Steve Sullivan","course"=>2,"year"=>2,"living_group"=>"Pi Lambda Phi","likes"=>["art","tech"])
  	unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    user2 = @neo.create_node("athena" => "fishr","id"=>unique_id,"name"=>"Ryan Fish","course"=>2,"year"=>2,"living_group"=>"Next House","likes"=>["art","tech"])
    unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
  	user3 = @neo.create_node("athena" => "ahuang27","id"=>unique_id,"name"=>"Alice Huang","course"=>2,"year"=>2,"living_group"=>"Maseeh","likes"=>["art","tech"])
    unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    nil_user = @neo.create_node("athena" => "_nil","id"=>unique_id,"name"=>"BLANK USER")

    @neo.add_node_to_index("nodes", "name", "jhaip", me)
    @neo.add_node_to_index("nodes", "name", "ssul", user1)
    @neo.add_node_to_index("nodes", "name", "fishr", user2)
    @neo.add_node_to_index("nodes", "name", "ahuang27", user3)
    @neo.add_node_to_index("nodes", "name", "_nil", nil_user)
  	
    id1 = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    id2 = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    id3 = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    id4 = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    id5 = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    id6 = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join

    rel1 = @neo.create_relationship("living group",me,user1)
    rel2 = @neo.create_relationship("living group",me,user3)
    rel3 = @neo.create_relationship("living_group",me,nil_user)
    @neo.set_relationship_properties(rel1, {"id" => id1})
    @neo.set_relationship_properties(rel2, {"id" => id1})
    @neo.set_relationship_properties(rel3, {"id" => id1})

  	rel4 = @neo.create_relationship("misc",me,user2)
    rel5 = @neo.create_relationship("misc",me,nil_user)
    @neo.set_relationship_properties(rel4, {"id" => id2})
    @neo.set_relationship_properties(rel5, {"id" => id2})

  	rel6 = @neo.create_relationship("work",me,user2)
  	rel7 = @neo.create_relationship("work",me,user3)
    rel8 = @neo.create_relationship("work",me,nil_user)
    @neo.set_relationship_properties(rel6, {"id" => id3})
    @neo.set_relationship_properties(rel7, {"id" => id3})
    @neo.set_relationship_properties(rel8, {"id" => id3})

    rel9 = @neo.create_relationship("work",user2,me)
    @neo.set_relationship_properties(rel9, {"id" => id4})

    rel10 = @neo.create_relationship("work",user2,user3)
    @neo.set_relationship_properties(rel10, {"id" => id5})

    rel11 = @neo.create_relationship("work",user3,user2)
    @neo.set_relationship_properties(rel11, {"id" => id6})

  	render :text => "database created"

  end

  def datapull
    # should be passed params: name, type, id, and parent name
  	@neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
    if params[:type] == "person"
    	query = @neo.execute_query("START n=node(*) WHERE n.athena ='#{params[:name]}' RETURN n.name, n.course, n.year, n.living_group, n.id, n.likes;")["data"][0]
      #query2 = @neo.execute_query("START n=node(*) MATCH n-[r]->() WHERE n.athena ='#{params[:name]}' RETURN collect(type(r)), collect(r.id);")["data"][0]
      query2 = @neo.execute_query("START n=node(*) MATCH n-[r]->() WHERE n.athena ='#{params[:name]}' RETURN type(r), r.id;")["data"]
    	name = query[0]
    	course = query[1]
    	year = query[2]
    	living_group = query[3]
      unique_id = query[4]
    	likes = query[5]
    	children = Array.new
      puts "-----------------------------------"
      puts query2
      connections = query2.uniq
      connections.each do |c|
        category_name = c[0]
        category_id = c[1]
        t = {:name => category_name, :type => "category", :id => category_id, :children => Array.new }
        children << t
      end
    	ret = {:details => {:name => name, :course => course, :year => year, :living_group => living_group, :likes => likes},
             :graph   => {:name => params[:name], :type => params[:type], :id => unique_id, :children => children }
            }
    	render :json => ret.to_json
    elsif params[:type] == "category"
      query = @neo.execute_query("START n=node(*) MATCH (n)-[:#{params[:name]}]-(x) WHERE n.athena ='#{params[:parent]}' RETURN x.athena, x.id;")["data"]
      connections = query
      children = Array.new
      connections.each do |c|
        #unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
        person_athena = c[0]
        person_id = c[1]
        t = {:name => person_athena, :type => "person", :id => person_id, :children => Array.new }
        children << t
      end
      ret = {:details => {},
             :graph   => {:name => params[:name], :type => params[:type], :id => params[:id], :children => children }
            };
      render :json => ret.to_json
    end
  end

  def datapush
    if current_user == nil
      redirect_to( root_path, :notice => "Couldn't find current user") and return
    end

    category_name = params[:category]

    current_email = current_user.email
    athena_name = current_email[/[^@]+/]

    @neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")

    me_node = @neo.get_node_index("nodes", "name", athena_name) 
    null_node = @neo.get_node_index("nodes", "name", "_nil") 

    rel1 = @neo.create_relationship(category_name,me,null_node)
    unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    @neo.set_relationship_properties(rel1, {"id" => unique_id})

    ret = {:response => "All good"}
    render :json => ret.to_json
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
