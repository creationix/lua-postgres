Good Day!

**Caution:** To use PostgreSQL, it's best to use the version ( **10** ). If you use higher version, make sure to config the pg_hba.conf and set the password method to MD5. Also, make sure to setup your password with md5 while set the user's password for the server. 

Example:

```lua
local psql = require("coro-postgres")

local config = {
    username = "username",
    password = "password",
    database = "your db name"
    --port = if any
    --host = if any
}

local sql = psql.connect(config)
local query = sql.query

local form = "SELECT * FROM somewhere;

local result = query(form)

p(result.rows)
```


Make sure to use a `rows` property to get the data from the sql result. 
Make sure to have a nil safety like below:
```lua
local result = query(form)

local data = results and results.rows or {} -- nil safety

print(data)
```

For getting single specific data like using a single condition

```lua
local form = "SELECT * FROM somewhere WHERE id = 1;

local result = query(form)

local data = results and results.rows or {} -- nil safety

print(data[1])
```

`coro-postgres` already using MUTEX. However, if you want to use MUTEX additionally, you may config your script like below:

```lua
local psql = require("coro-postgres")
local mutex = require 'mutex-wrapper'
local config = {
    username = "username",
    password = "password",
    database = "your db name"
    --port = if any
    --host = if any
}

local sql = psql.connect(config)
local sqlquery = sql.query

local query = mutex()(sqlquery)

local form = "SELECT * FROM somewhere;

local result = query(form)

p(result.rows)
```


**COUTION:** For the SQL database table data, make sure not to blank any data, it might return you a nil value. And also, it may cause break the script due to nil safety issue.


For closing the connection use this line.
```lua
sql.close()
```
