/*
 * esqlite -- an erlang sqlite nif.
*/

#include <stdio.h> /* for debugging */
#include <erl_nif.h>

#include "sqlite3.h"

#define MAX_PATHNAME 512 /* unfortunately not in sqlite.h. */

static ERL_NIF_TERM _atom_ok;
static ERL_NIF_TERM _atom_error;

/*
 * Open database. Expects utf-8 input
*/
static ERL_NIF_TERM esqlite_open_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    int rc;
    char filename[MAX_PATHNAME];
    sqlite3 *db;
   
    /* TODO ignore the utf-8 stuff for now */
    if(!enif_get_string(env, argv[0], filename, MAX_PATHNAME, ERL_NIF_LATIN1))
        return enif_make_badarg(env);   

    /* open the database */
    rc = sqlite3_open(filename, &db);
    if( rc ) {
      fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
      sqlite3_close(db);
      /* maak een error tuple */
    }

    /* and wrap it in an erlang resource */
    fprintf(stderr, "The database is open.\n");

    sqlite3_close(db);

    fprintf(stderr, "And closed\n");
    
    return enif_make_tuple2(env, _atom_ok, _atom_ok);
}


static int on_load(ErlNifEnv* env, void** priv, ERL_NIF_TERM info)
{
  _atom_ok = enif_make_atom(env, "ok");
  _atom_error = enif_make_atom(env, "error");

  return 0;
}


static ErlNifFunc nif_funcs[] = {
  {"open", 1, esqlite_open_nif},
};

ERL_NIF_INIT(esqlite, nif_funcs, on_load, NULL, NULL, NULL);
