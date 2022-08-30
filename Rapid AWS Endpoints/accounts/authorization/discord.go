package Auth

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

// Discord Constants
const (
	CLIENT_ID     = "CLIENT ID"
	CLIENT_SECRET = "CLIENT SECRET"
	REDIRECT_URI  = "REDIRECT URI"
)

// OAUTH Url
var OAUTH_URL string = fmt.Sprintf("OAUTH URL %s %s", CLIENT_ID, REDIRECT_URI)

// Get Discord User Data
func GetDiscordUserData(token string) map[string]string {
	var (
		client *http.Client = &http.Client{}
		data   map[string]string
		req, _ = http.NewRequest("GET", "https://discord.com/api/users/@me", nil)
	)

	// Creating Request
	req.Header = http.Header{
		"Content-Type":  []string{"application/json"},
		"Authorization": []string{"Bearer " + token},
	}
	// Send Request and return json
	var res, _ = client.Do(req)
	json.NewDecoder(res.Body).Decode(&data)
	return data
}

// Get the users discord token.
func GetDiscordUserToken(code string) map[string]string {
	var (
		// Request Client and Data map
		client *http.Client = &http.Client{}
		data   map[string]string

		// Request body
		body string = fmt.Sprintf(
			"client_id=%s&client_secret=%s&grant_type=authorization_code&redirect_uri=%s&code=%s&scope=identify",
			CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, code)

		// Send http request
		req, _ = http.NewRequest("POST", "https://discordapp.com/api/oauth2/token", bytes.NewBuffer([]byte(body)))
	)
	// Set the request headers
	req.Header = http.Header{
		"Content-Type": []string{"application/x-www-form-urlencoded"},
		"Accept":       []string{"application/json"},
	}

	// Send Request and return json
	var res, _ = client.Do(req)
	json.NewDecoder(res.Body).Decode(&data)

	// Return encoded data
	return data
}
