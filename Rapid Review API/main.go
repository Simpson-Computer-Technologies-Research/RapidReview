package main

import (
	"database/sql"
	"fmt"
	"net/http"
	"os"
	Accounts "rapid_review_api/endpoints/Accounts"
	"rapid_review_api/endpoints/Blocked"
	Roles "rapid_review_api/endpoints/Roles"

	"github.com/gorilla/mux"
)

func main() {
	var db, _ = sql.Open("mysql", "database")
	defer db.Close()

	// API Router
	r := mux.NewRouter()
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { fmt.Fprintf(w, `Welcome to Rapid Api`) }).Methods("GET")

	// Add/Remove Roles
	r.HandleFunc("/remove-role/{guildId}/{userId}/{roleId}", Roles.RoleFuncHandler("DELETE")).Methods("GET")
	r.HandleFunc("/add-role/{guildId}/{userId}/{roleId}", Roles.RoleFuncHandler("PUT")).Methods("GET")

	// Account Linking
	r.HandleFunc("/accounts/linked/{user}", Accounts.GetLinkedAccountsHandler(db)).Methods("GET")
	r.HandleFunc("/accounts/linked/delete/{user}", Accounts.DeleteLinkedAccountHandler(db)).Methods("GET")
	r.HandleFunc("/accounts/link/{user}/{auth_token}", Accounts.DiscordRedirectHandler).Methods("GET")
	r.HandleFunc("/accounts/link/success", Accounts.AccountLinkTokenHandler(db)).Methods("GET")

	// Blocked Accounts
	r.HandleFunc("/users/block/{user}", Blocked.BlockUser(db)).Methods("GET")
	r.HandleFunc("/users/unblock/{user}", Blocked.UnblockUser(db)).Methods("GET")
	r.HandleFunc("/users/blocked/{user}", Blocked.GetBlockedUsers(db)).Methods("GET")

	// Handle Router Calls
	http.Handle("/", r)
	http.ListenAndServe(":"+os.Getenv("PORT"), nil)
}
