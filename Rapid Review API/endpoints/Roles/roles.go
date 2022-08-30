package Roles

import (
	"encoding/json"
	"net/http"
	Auth "rapid_review_api/authorization"

	"github.com/gorilla/mux"
)

func Response(w http.ResponseWriter, m map[string]interface{}) {
	var data, _ = json.Marshal(m)
	w.Write(data)
}

func RoleFuncHandler(option string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var (
			vars    map[string]string = mux.Vars(r)
			guildId string            = vars["guildId"]
			userId  string            = vars["userId"]
			roleId  string            = vars["roleId"]
		)

		// Getting the auth and ref token
		var (
			authToken     string = r.Header.Get("auth_token")
			userAuthToken string = r.Header.Get("user_auth_token")
			userHash      string = r.Header.Get("user")
		)

		// Token Verification
		if authToken == "" || userHash == "" || userAuthToken == "" {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (1)"})
			return
		}
		if !Auth.CheckTokenUsage(authToken, userHash) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (2)"})
			return
		}
		if !Auth.CheckAuthToken(userAuthToken, guildId+":"+roleId+":"+userId) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (3)"})
			return
		}
		if !Auth.CheckAuthToken(authToken, userHash) {
			Response(w, map[string]interface{}{"status": 401, "response": "invalid token (4)"})
			return
		}

		// Send Discord API Request
		var (
			client *http.Client = &http.Client{}
			req, _              = http.NewRequest(option, "https://discord.com/api/v9/guilds/"+guildId+"/members/"+userId+"/roles/"+roleId, nil)
		)
		// Set the requwest headers
		req.Header = http.Header{
			"Content-Type":  []string{"application/json"},
			"Authorization": []string{"Bot TOKEN"},
		}

		// Send the request
		var res, _ = client.Do(req)
		if res.StatusCode == 204 {
			Response(w, map[string]interface{}{"status": 200, "response": "success"})
			return
		}
		Response(w, map[string]interface{}{"status": 500, "response": "discord error"})
	}
}
