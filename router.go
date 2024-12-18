// router.go
package main

import(
   "net/http"
   "github.com/asccclass/sherryserver"
   "github.com/asccclass/sherryserver/libs/ntfy"
   "github.com/asccclass/sherryserver/libs/oauth"
)

func NewRouter(srv *SherryServer.Server, documentRoot string)(*http.ServeMux) {
   router := http.NewServeMux()

   // Static File server
   staticfileserver := SherryServer.StaticFileServer{documentRoot, "index.html"}
   staticfileserver.AddRouter(router)

   // Oauth
   oauth, err := Oauth.NewOauth(srv)
   if err == nil {
      oauth.AddRouter(router)
   }
   // Notify service
   nt, err := Ntfy.NewNtfy(srv)
   if err == nil {
      nt.AddRouter(router)
   }
   // socketio
   srv.Socketio.AddRouter(router)
   return router
}
