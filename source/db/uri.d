module db.uri;

struct Uri
{
    string protocol;
    string username;
    string password;
    string domain;
    short port;
    string path;
    string[string] params;
}
