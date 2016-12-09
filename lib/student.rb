require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id

  def initialize(id=nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =  <<-SQL
      DROP TABLE students
        SQL
    DB[:conn].execute(sql)
  end

  def save
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

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.new_from_db(row)
    student = Student.new(row[0],row[1],row[2])
    student.save
    student
  end

  def self.find_by_name(name)
    #binding.pry
    Student.all.select {|student| student if student.name == name}.first
  end

  def self.all
    sql = <<-SQL
          SELECT *
          FROM students
        SQL
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

end
