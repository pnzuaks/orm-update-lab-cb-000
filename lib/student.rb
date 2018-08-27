require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table()
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
        SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table()
    sql = <<-SQL
      DROP TABLE IF EXISTS students
        SQL
      DB[:conn].execute(sql)
  end

  def save()
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save()
    student
  end

  def self.new_from_db(row)
     # create a new Student object given a row from the database
     student = self.new(row[1], row[2], row[0])
     student
   end

   def self.find_by_name(name)
   sql = <<-SQL
     SELECT *
     FROM students
     WHERE name = ?
     LIMIT 1
   SQL

    found = DB[:conn].execute(sql,name)
    puts self.new_from_db(found[0])

 end

 def update()
   sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
   DB[:conn].execute(sql, self.name, self.grade, self.id)
 end
end
