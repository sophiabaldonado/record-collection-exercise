require 'sqlite3'
require 'CSV'

class ReleaseDatabase
  FILE_PATH = 'source/20160406-record-collection.csv'

  attr_reader :db

  def initialize(dbname = "releases")
    @db = SQLite3::Database.new "database/#{dbname}.db"
  end

  def reset_schema!
    # table name: albums
    # label_code,artist,title,label,format,released,date_added
    # BLOB, TEXT, TEXT, TEXT, TEXT, INTEGER, TEXT
    query = <<-CREATE
      CREATE TABLE albums (
      id INTEGER PRIMARY KEY,
      label_code BLOB,
      artist TEXT NOT NULL,
      title TEXT NOT NULL,
      label TEXT,
      format TEXT,
      released INTEGER,
      date_added TEXT
      );
    CREATE
    @db.execute("DROP TABLE IF EXISTS albums;")
    @db.execute(query)
  end

  def load!
    insert_statement = <<-INSERT
      INSERT INTO albums (
        label_code, artist, title, label, format, released, date_added
      ) VALUES (
        :label_code, :artist, :title, :label, :format, :released, :date_added
      );
    INSERT

    # basically magic that makes it so i can just throw data at it and it works
    prepared_statement = @db.prepare(insert_statement)

    # now that there is a prepared_statement, we itrate the csv and populate the db
    CSV.foreach(FILE_PATH, headers: true) do |row|
      prepared_statement.execute(row.to_h)
    end
  end
end

release_db = ReleaseDatabase.new
release_db.reset_schema!

release_db.load!
