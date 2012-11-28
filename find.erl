-module(find).
-include_lib("xmerl/include/xmerl.hrl").
-compile(export_all).

-type graph() :: term().
-type graph_node() :: term().
-type xml_node() :: term().
-type path() :: string().
-type graph_edge() :: string().

-spec run() -> graph().
run() ->
  SongList = load_songs("SongLibrary.xml"),
  io:format("~s~n", ["Loaded Songs"]),
  build_graph(SongList).

-spec build_graph(path()) -> graph().
build_graph(SongList) ->
  Graph = digraph:new(),
  lists:map(fun(SongTitle) -> add_song_node(Graph, SongTitle) end, SongList),
  io:format("~s~n", ["Added Nodes"]),
  lists:map(fun(SongTitle) -> add_song_graph_edges(Graph, SongTitle) end, SongList),
  io:format("~s~n", ["Added Edges"]),
  Graph.

-spec load_songs(path()) -> [string()].
load_songs(Filename) ->
  {ParsedFile, _} = xmerl_scan:file(Filename, []),
  SongNodes = xmerl_xpath:string("/Library/Artist/Song", ParsedFile),
  SongNames = lists:map(fun(SongNode) -> song_name(SongNode) end, SongNodes),
  lists:usort(SongNames).

-spec song_name(xml_node()) -> string().
song_name(Node) when is_record(Node, xmlElement)->
  Attributes = Node#xmlElement.attributes,
  [Name | _] = lists:filter(fun(Attr) -> Attr#xmlAttribute.name =:= name end, Attributes),
  Name#xmlAttribute.value.

-spec song_node(string()) -> {string(), string(), string()}.
song_node(Title) ->
  [F | _] = Title,
  First = string:to_upper(F),
  Last = string:to_upper(lists:last(Title)),
  {First, Title, Last}.

-spec add_song_node(graph(), string()) -> graph_node().
add_song_node(G, Title) ->
  digraph:add_vertex(G, song_node(Title)).

-spec add_song_graph_edges(graph(), string()) -> graph_edge().
add_song_graph_edges(G, Title) ->
  V1 = song_vertex(G, Title),
  io:format("~p~n", [V1]),
  {_, _, Last} = V1,
  Vertices = lists:filter(fun(V) -> {First, _, _} = V, First =:= Last end, digraph:vertices(G)),
  io:format("~p~n~n", [Vertices]),
  lists:map(fun(V) -> digraph:add_edge(G, V1, V) end, Vertices).

-spec song_vertex(graph(), string()) -> graph_node().
song_vertex(G, Title) ->
  [SongVertex|_] = lists:filter(fun(V) -> {_, T, _} = V, T =:= Title end, digraph:vertices(G)),
  SongVertex.

-spec playlist(term(), string(), string()) -> term().
playlist(G, StartTitle, EndTitle) ->
  V1 = song_vertex(G, StartTitle),
  V2 = song_vertex(G, EndTitle),
  digraph:get_path(G, V1, V2).

