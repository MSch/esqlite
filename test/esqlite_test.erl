%%
%% Test suite for esqlite.
%%

-module(esqlite_test).

-include_lib("eunit/include/eunit.hrl").

open_single_database_test() ->
    {ok, _C1} = esqlite3:open("test.db"),
    ok.

open_multiple_same_databases_test() ->
    {ok, _C1} = esqlite3:open("test.db"),
    {ok, _C2} = esqlite3:open("test.db"),
    ok.

open_multiple_different_databases_test() ->
    {ok, _C1} = esqlite3:open("test1.db"),
    {ok, _C2} = esqlite3:open("test2.db"),
    ok.

simple_query_test() ->
    {ok, Db} = esqlite3:open(":memory:"),
    ok = esqlite3:exec("begin;", Db),
    ok = esqlite3:exec("create table test_table(one varchar(10), two int);", Db),
    ok = esqlite3:exec(["insert into test_table values(", "\"hello1\"", ",", "10" ");"], Db),
    ok = esqlite3:exec(["insert into test_table values(", "\"hello2\"", ",", "11" ");"], Db),
    ok = esqlite3:exec(["insert into test_table values(", "\"hello3\"", ",", "12" ");"], Db),
    ok = esqlite3:exec(["insert into test_table values(", "\"hello4\"", ",", "13" ");"], Db),
    ok = esqlite3:exec("commit;", Db),
    ok = esqlite3:exec("select * from test_table;", Db),
    ok.

prepare_test() ->
    {ok, Db} = esqlite3:open(":memory:"),
    esqlite3:exec("begin;", Db),
    esqlite3:exec("create table test_table(one varchar(10), two int);", Db),
    {ok, Statement} = esqlite3:prepare("insert into test_table values(\"one\", 2)", Db),
    
    '$done' = esqlite3:step(Statement),

    ok = esqlite3:exec(["insert into test_table values(", "\"hello4\"", ",", "13" ");"], Db), 

    %% Check if the values are there.
    [{"one", 2}, {"hello4", 13}] = esqlite3:q("select * from test_table order by two", Db),
    esqlite3:exec("commit;", Db),
    esqlite3:close(Db),

    ok.

bind_test() ->
    {ok, Db} = esqlite3:open(":memory:"),
    ok = esqlite3:exec("begin;", Db),
    ok = esqlite3:exec("create table test_table(one varchar(10), two int);", Db),
    ok = esqlite3:exec(["insert into test_table values(", "\"hello1\"", ",", "10" ");"], Db),
    ok = esqlite3:exec(["insert into test_table values(", "\"hello2\"", ",", "11" ");"], Db),
    ok = esqlite3:exec(["insert into test_table values(", "\"hello3\"", ",", "12" ");"], Db),
    ok = esqlite3:exec(["insert into test_table values(", "\"hello4\"", ",", "13" ");"], Db),
    ok = esqlite3:exec("commit;", Db),

    %% Create a prepared statement
    {ok, Statement} = esqlite3:prepare("insert into test_table values(?1, ?2)", Db),
    esqlite3:bind(Statement, [one, 2]),
    esqlite3:step(Statement),
    esqlite3:bind(Statement, ["three", 4]),
    esqlite3:step(Statement),
    esqlite3:bind(Statement, [<<"five">>, 6]),
    esqlite3:step(Statement),

    [{"one", 2}] = esqlite3:q("select * from test_table where two = '2'", Db),
    [{"three", 4}] = esqlite3:q("select * from test_table where two = 4", Db),
    [{<<"five">>, 6}] = esqlite3:q("select * from test_table where two = 6", Db),

    ok.

%%gen_db_test() ->
 %%   {ok, Conn} = gen_db:open(sqlite, ":memory:"),
 %%   [] = gen_db:execute("create table some_shit(hole_one varchar(10), hole_two int);", [], Conn),
 %%   [] = gen_db:execute("insert into some_shit values('dung', 100);", Conn),
 %%   [] = gen_db:execute("insert into some_shit values(?, ?);", ["manure", 1000], Conn),
 %%   ok.





    
	 

    

    

    

    
    

    
    
    
