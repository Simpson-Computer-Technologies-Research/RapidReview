package Blocked

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	Auth "rapid_review_api/authorization"
	Database "rapid_review_api/database"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/mux"
)

// API Response Function
func Response(w http.ResponseWriter, m map[string]interface{}) {
	var data, _ = json.Marshal(m)
	w.Write(data)
}

// Unblock an user
func UnblockUser(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var (
			userToUnblock string = r.Header.Get("unblock_user")
			authToken     string = r.Header.Get("auth_token")
			userHash      string = mux.Vars(r)["user"]
		)

		// Check Auth Token
		if !Auth.CheckAuthToken(authToken, userHash+":"+userToUnblock) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (1)"})
			return
		}
		if !Auth.CheckTokenUsage(authToken, userHash) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (2)"})
			return
		}
		if Database.Exists(db, fmt.Sprintf("SELECT * FROM blocked_users WHERE user_hash = '%s' AND blocked_user = '%s'", userHash, userToUnblock)) {
			if Database.Delete(db, fmt.Sprintf("DELETE FROM blocked_users WHERE user_hash = '%s' AND blocked_user = '%s'", userHash, userToUnblock)) {
				Response(w, map[string]interface{}{"status": 200, "response": "successfully unblocked account"})
				return
			}
		}
		Response(w, map[string]interface{}{"status": 401, "response": "failed to unblock account"})
	}
}

// Block an user
func BlockUser(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var (
			userToBlock string = r.Header.Get("block_user")
			authToken   string = r.Header.Get("auth_token")
			userHash    string = mux.Vars(r)["user"]
		)

		// Check Auth Token
		if !Auth.CheckAuthToken(authToken, userHash+":"+userToBlock) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (1)"})
			return
		}
		if !Auth.CheckTokenUsage(authToken, userHash) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (2)"})
			return
		}

		if !Database.Exists(db, fmt.Sprintf("SELECT * FROM blocked_users WHERE user_hash = '%s' AND blocked_user = '%s'", userHash, userToBlock)) {
			if Database.Update(db, fmt.Sprintf("INSERT INTO blocked_users (user_hash, blocked_user) VALUES ('%s', '%s')", userHash, userToBlock)) {
				Response(w, map[string]interface{}{"status": 200, "response": "successfully blocked user"})
				return
			}
		}
		Response(w, map[string]interface{}{"status": 401, "response": "failed to block user"})
	}
}

// Check if an user is blocked for another user
func GetBlockedUsers(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var (
			userHash string   = mux.Vars(r)["user"]
			users    []string = Database.Select(db, fmt.Sprintf("SELECT blocked_user FROM blocked_users WHERE user_hash = '%s'", userHash))
		)
		Response(w, map[string]interface{}{"status": 200, "response": users})
	}
}
