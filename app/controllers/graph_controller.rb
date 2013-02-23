class GraphController < ApplicationController

  skip_before_filter :require_login, :except => [:datapush]

  # GET /graph
  # Main graph page
  def index

    current_email = current_user.email
    @athena_name = current_email[/[^@]+/]

    @neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
    person = @neo.get_node_index("nodes", "name", @athena_name)
    if person == nil
      # user not already connected to in the graph, need to them to setup their node
      puts "person #{@athena_name} not found, redirecting to profile page to create them"
      redirect_to :profile
    else
      # if node exists, but doesn't have the required information, redirect user to input info
      props = @neo.get_node_properties(person, ["course","year"])
      if props["course"] == nil or props["course"] == "?"
        puts "properties for #{@athena_name} found to be empty, redirecting to profile to fill them out"
        redirect_to :profile
      end
    end

  end

  # GET /users
  def profile
  end

  # POST /profile
  # when submit updated profile information, profile_push updates information in database accordingly
  def profile_push

    # can only update profile if logged in
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

    # if checked box that liked something, add a string description to the likes array
    if params[:ck_family]
      likes << "Family"
    end
    if params[:ck_travel]
      likes << "Travel"
    end
    if params[:ck_education]
      likes << "Education"
    end
    if params[:ck_organization]
      likes << "Organization"
    end
    if params[:ck_leadership]
      likes << "Leadership"
    end
    if params[:ck_outdoors]
      likes << "The outdoors"
    end
    if params[:ck_fun]
      likes << "Fun"
    end
    if params[:ck_making_things]
      likes << "Making things"
    end
    if params[:ck_staying_fit]
      likes << "Staying fit"
    end
    if params[:ck_music]
      likes << "Music"
    end
    if params[:ck_giving_back]
      likes << "Giving back"
    end

    # generate unique id for the newly created node
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

    work_connections = @neo.get_node_relationships(person, "out", "work")
    live_connections = @neo.get_node_relationships(person, "out", "living group")

    null_node = @neo.get_node_index("nodes", "name", "_nil") 

    # all users should have living and working connection groups
    if !work_connections
      puts "WORK CATEGORY NOT FOUND, CREATING WORK CATEGORY"
      rel1 = @neo.create_relationship("work",person,null_node)
      unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
      @neo.set_relationship_properties(rel1, {"id" => unique_id})
    end
    if !live_connections
      puts "LIVING GROUP CATEGORY NOT FOUND, CREATING LIVING GROUP CATEGORY"
      rel1 = @neo.create_relationship("living group",person,null_node)
      unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
      @neo.set_relationship_properties(rel1, {"id" => unique_id})
    end

    redirect_to(:graph)
  end

  # GET /creategraph
  # call to setup database
  # - creates an index to put users in
  # - creates a nil user so that category connections always have someone to connect to
  #   even though it wouldn't be shown on the graph
  def create
  	@neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")

    @neo.create_node_index("nodes")

    unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    nil_user = @neo.create_node("athena" => "_nil","id"=>unique_id,"name"=>"BLANK USER","course"=>"?","year"=>"?","living_group"=>"?","likes"=>["empty"])
    @neo.add_node_to_index("nodes", "name", "_nil", nil_user)
  	render :text => "database created"

  end

  # GET /datapull
  # Get information about connections from a node
  # @params: name   (athena name of user wanting data for)
  #         type   (category/person - type of node expanding)
  #         id     (id of node wanting information about)
  #         parent (for type=category: the user owning the category)
  def datapull
  	@neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")

    if params[:type] == "person"

    	query = @neo.execute_query("START n=node(*) WHERE n.athena ='#{params[:name]}' RETURN n.name, n.course, n.year, n.living_group, n.id, n.likes;")["data"][0]
      query2 = @neo.execute_query("START n=node(*) MATCH (n)-[r]->() WHERE n.athena ='#{params[:name]}' RETURN type(r), r.id;")["data"]
    	name = query[0]
    	course = query[1]
    	year = query[2]
    	living_group = query[3]
      unique_id = query[4]
    	likes = query[5]
    	children = Array.new

      connections = query2.uniq
      connections.each do |c|
        category_name = c[0]
        category_id = c[1]
        t = {:name => category_name, :type => "category", :id => category_id, :children => Array.new }
        children << t
      end
    	ret = {:details => {:name => name, :course => course, :year => year, :living_group => living_group, :likes => likes},
             :graph   => {:name => params[:name], :type => params[:type], :id => unique_id, :children => children, :likes => likes }
            }
    	render :json => ret.to_json

    elsif params[:type] == "category"

      query = @neo.execute_query("START n=node(*) MATCH (n)-[:`#{params[:name]}`]->(x) WHERE n.athena ='#{params[:parent]}' RETURN x.athena, x.id, x.likes;")["data"]
      connections = query
      children = Array.new
      connections.each do |c|
        person_athena = c[0]
        person_id = c[1]
        person_likes = c[2]
        if person_athena != "_nil"
          t = {:name => person_athena, :type => "person", :id => person_id, :likes => person_likes, :children => Array.new }
          children << t
        end
      end
      ret = {:details => {},
             :graph   => {:name => params[:name], :type => params[:type], :id => params[:id], :children => children }
            };
      render :json => ret.to_json
    end
  end

  # POST /datapush
  # add a new connection to a user/category in the database
  # @params: new_category_name - name of new category to attach to current user
  #          new_connection_name - name of user to connect to
  #          category - if new_connection_name exist: the name of the category connecting through
  def datapush
    if current_user == nil
      redirect_to( root_path, :notice => "Couldn't find current user") and return
    end

    current_email = current_user.email
    athena_name = current_email[/[^@]+/]

    @neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")

    ret = {:response => "All good"}

    if params[:new_category_name]
      category_name = params[:new_category_name]

      puts "Trying to add category #{category_name} to #{athena_name}"

      me_node = @neo.get_node_index("nodes", "name", athena_name) 
      null_node = @neo.get_node_index("nodes", "name", "_nil") 

      ret = {:response => "All good"}
      if @neo.get_node_relationships(me_node, "out", category_name) != nil
        ret = {:response => "repeated category"}
      else
        rel1 = @neo.create_relationship(category_name,me_node,null_node)
        unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
        @neo.set_relationship_properties(rel1, {"id" => unique_id})
      end
    else
      # adding new connection

      connection_name = params[:new_connection_name]
      category = params[:category]

      puts "Trying to add connection #{connection_name} in category #{category} to #{athena_name}"

      me_node = @neo.get_node_index("nodes", "name", athena_name) 
      connection_node = @neo.get_node_index("nodes", "name", connection_name)

      id_rel = @neo.get_node_relationships(me_node, "out", category)[0]
      category_id = @neo.get_relationship_properties(id_rel, "id")["id"]

      if connection_node == nil 
        #user doesn't exist

        puts "node doesn't exist, creating one"
        unique_id = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
        connection_node = @neo.create_node("athena"=>connection_name,"id"=>unique_id,"name"=>connection_name,"course"=>"?","year"=>"?","living_group"=>"?","likes"=>["empty"])
        @neo.add_node_to_index("nodes", "name", connection_name, connection_node)

        #create connection
        rel = @neo.create_relationship(category, me_node, connection_node)
        @neo.set_relationship_properties(rel, {"id" => category_id})
      else 
        #user exists

        query = @neo.execute_query("START n=node(*) MATCH (n)-[:`#{category}`]->(x) WHERE n.athena ='#{athena_name}' RETURN x.athena, x.id;")["data"]
        puts "query results for connection data"
        puts query
        connection_exists = false

        query.each do |c|
          if (c[0] == connection_name)
            connection_exists = true
            break
          end
        end
        if !connection_exists
          puts "no existing path found, creating new connection"
          query_str = "START n1=node:nodes(name = '#{athena_name}'), n2=node:nodes(name = '#{connection_name}')";
          query_str += " CREATE n1-[r:`#{category}` {id: '#{category_id}' }]->n2"
          query_str += " RETURN r;"
          puts "QUERY SUBMITTED:"
          puts query_str
          @neo.execute_query(query_str);
        else
          puts "existing path found, not creating new connection"
          ret = {:response => "repeated connection"}
        end
      end
      
    end

    render :json => ret.to_json
  end

  # DELETE /datadelete
  # removes a new connection to a user/category in the database
  # @params: name - name user removing connection to
  #          category - if name param exists: the category that connected you to user
  #                   - if not: the name of the category to remove
  def datadelete

    current_email = current_user.email
    athena_name = current_email[/[^@]+/]

    @neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")

    category_name = params[:category]

    ret = {:response => "All good"}

    if category_name == "living group" or category_name == "work"
      ret = {:response => "Can't delete living gorup or work categories!"}
    else
      if params[:name]
        connection_name = params[:name]
        puts "DELETING CONNECTION TO #{connection_name} IN CATEGORY #{category_name}"
        @neo.execute_query("START n=node(*) MATCH (n)-[r:`#{category_name}`]->(x) WHERE (n.athena ='#{athena_name}' and x.athena='#{connection_name}') DELETE r;")
      else
        puts "DELETING CATEGORY #{category_name}"
        @neo.execute_query("START n=node(*) MATCH (n)-[r:`#{category_name}`]->() WHERE n.athena ='#{athena_name}' DELETE r;")
      end
    end
    
    render :json => ret.to_json
  end

  # GET /userpull
  # autocomplete data source
  # looking for substring params[:term] in a large JSON file containing the mapping of every MIT student to their email
  # THIS IS SLOW - parsing through a gigantic text file every time something is typed - should be moved into a database
  #
  # @params: term - what the user has typed in the autocomplete text box so far
  # @returns JSON object of top 8 closed matches to be displayed by autocomplete
  def userpull

    puts "URL:"
    puts "#{Rails.public_path}/mit.txt"
    file = File.new("#{Rails.public_path}/mit.txt")
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
