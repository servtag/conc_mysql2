#conc_mysql2
Concurrent mysql requests using mysql2 gem.

##Usage
``` ruby
# Create pool that supports up to 5 concurrent requests to mysql.
pool = ConcMysql2::Pool.new(size: 5,
                            host: 'localhost',
                            database: 'my_database'
                            username: 'xxxxx',
                            password: 'xxxxx')

# Fire concurrent queries.                        
res1 = pool.query('SELECT * FROM foo')
res2 = pool.query('SELECT * FROM bar')
  
# Block until result is available.
puts res1.to_a.inspect
puts res2.to_a.inspect
```

##Contributing to conc_mysql2
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

##Copyright
Copyright (c) 2014 Ströer Mobile Media. See LICENSE.txt for
further details.

