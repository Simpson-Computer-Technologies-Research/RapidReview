package Accounts

import (
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	Auth "rapid_review_api/authorization"
	Database "rapid_review_api/database"
	"strings"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/mux"
)

// API Response Function
func Response(w http.ResponseWriter, m map[string]interface{}) {
	var data, _ = json.Marshal(m)
	w.Write(data)
}

// Discord OAuth Redirect Handler
func DiscordRedirectHandler(w http.ResponseWriter, r *http.Request) {
	var (
		authToken string = mux.Vars(r)["auth_token"]
		userHash  string = mux.Vars(r)["user"]
		state     string = base64.StdEncoding.EncodeToString([]byte(userHash + ":" + authToken))
	)
	http.Redirect(w, r, Auth.OAUTH_URL+"&state="+state, http.StatusTemporaryRedirect)
}

// Get a list of linked accounts
func GetLinkedAccountsHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var (
			userHash string   = mux.Vars(r)["user"]
			users    []string = Database.Select(db, fmt.Sprintf("SELECT user_name FROM connections WHERE user_hash = '%s'", userHash))
		)
		Response(w, map[string]interface{}{"status": 200, "response": users})
	}
}

// Delete a linked account from the database
func DeleteLinkedAccountHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var (
			authToken    string = r.Header.Get("auth_token")
			userToDelete string = r.Header.Get("delete_user")
			userHash     string = mux.Vars(r)["user"]
		)

		// Check Auth Token
		if !Auth.CheckAuthToken(authToken, userHash+":"+userToDelete) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (1)"})
			return
		}
		if !Auth.CheckTokenUsage(authToken, userHash) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (2)"})
			return
		}
		// Update database
		if Database.Exists(db, fmt.Sprintf("SELECT * FROM connections WHERE user_hash = '%s' AND user_name = '%s'", userHash, userToDelete)) { // if the user exists
			if Database.Delete(db, fmt.Sprintf("DELETE FROM connections WHERE user_hash = '%s' AND user_name = '%s'", userHash, userToDelete)) {
				Response(w, map[string]interface{}{"status": 200, "response": "successfully unlinked account"})
				return
			}
		}
		Response(w, map[string]interface{}{"status": 401, "response": "failed to unlink account"})
	}
}

// Add the user to the database after discord verification
func AccountLinkTokenHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var (
			_state string = r.URL.Query()["state"][0]
			code   string = r.URL.Query()["code"][0]
		)

		// Get the user hash and user auth token
		var (
			state, _         = base64.StdEncoding.DecodeString(_state)
			userHash  string = strings.Split(string(state), ":")[0]
			authToken string = strings.Split(string(state), ":")[1]
		)
		if !Auth.CheckAuthToken(authToken, userHash) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (3)"})
			return
		}
		if !Auth.CheckTokenUsage(authToken, userHash) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (4)"})
			return
		}

		// Get discord user access token and data
		var (
			token string            = Auth.GetDiscordUserToken(code)["access_token"]
			data  map[string]string = Auth.GetDiscordUserData(string(token))
		)
		if _, ok := data["message"]; ok {
			Response(w, map[string]interface{}{"status": 401, "response": "Verification Failed! Discord authentication error"})
			return
		}

		// Add the user to the database
		var (
			user   string = data["username"] + "#" + data["discriminator"]
			userId string = data["id"]
		)
		if !Database.Exists(db, fmt.Sprintf("SELECT user_id FROM connections WHERE user_id = %s AND user_hash = '%s'", userId, userHash)) {
			if Database.Update(db, fmt.Sprintf("INSERT INTO connections (user_hash, user_id, user_name) VALUES ('%s', %s, '%s')", userHash, userId, user)) {
				Response(w, map[string]interface{}{"status": 200, "response": "Verification Success!"})
				return
			}
		}
		Response(w, map[string]interface{}{"status": 401, "response": "Verification Failed!"})
	}
}
