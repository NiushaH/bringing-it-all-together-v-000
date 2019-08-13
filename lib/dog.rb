class Dog 
  attr_accessor :id, :name, :breed 
  
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name 
    @breed = breed 
  end 

  def self.create_table
    sql =  <<-SQL
      SELECT dogs
      FROM sqlite_master 
      WHERE type='table'
      AND
      tble_name='dogs'
    SQL
    
    create_table =   <<-SQL 
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
    SQL
    
    #why does this conditional need an 'end' and can't be written on one line? 
    if sql.empty? ? self.drop_table : DB[:conn].execute(create_table)
    end
  end 

  def self.drop_table
    sql = <<-SQL 
      DROP TABLE dogs
        SQL
    DB[:conn].execute(sql)
  end 

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
  def save
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if 
      dog.empty?
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      update      
    end
    self
  end
  
  def self.create(dog_attributes)
    new_dog = Dog.new(dog_attributes)
    new_dog.save
  end 
  
  def self.new_from_db(row)
    name =  row[1]
    breed = row[2]
    id = row[0]
    dog = self.new(name, breed, id)
    dog
  end

  # def self.find_by_name(name)
  #   SELECT * FROM dog WHERE name = ?
  # end 

end