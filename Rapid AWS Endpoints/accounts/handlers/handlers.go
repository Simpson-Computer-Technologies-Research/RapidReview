package handlers

import (
	Auth "aws-rapid-accounts/authorization"
	Database "aws-rapid-accounts/database"
	"database/sql"
	"encoding/base64"
	"fmt"
	"io/ioutil"
	"strings"

	"github.com/aws/aws-lambda-go/events"
)

func ApiResponse(status int, body string) (*events.APIGatewayProxyResponse, error) {
	return &events.APIGatewayProxyResponse{
		Headers:    map[string]string{"Content-Type": "application/json"},
		StatusCode: status,
		Body:       body,
	}, nil
}

func ApiResponseHTML(option string) (*events.APIGatewayProxyResponse, error) {
	var bytes, _ = ioutil.ReadFile(fmt.Sprintf("html/%v.html", option))
	return &events.APIGatewayProxyResponse{
		Headers:    map[string]string{"Content-Type": "text/html"},
		StatusCode: 200,
		Body:       string(bytes),
	}, nil
}

func DiscordRedirectHandler(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	var (
		authToken string = req.QueryStringParameters["auth_token"]
		userHash  string = req.QueryStringParameters["user"]
		state     string = base64.StdEncoding.EncodeToString([]byte(userHash + ":" + authToken))
	)
	return &events.APIGatewayProxyResponse{
		StatusCode: 301,
		Headers: map[string]string{
			"Location": Auth.OAUTH_URL + "&state=" + state,
		},
	}, nil
}

// Get a list of linked accounts
func GetLinkedAccounts(req events.APIGatewayProxyRequest, db *sql.DB) (*events.APIGatewayProxyResponse, error) {
	var users []string = Database.Select(
		db, fmt.Sprintf("SELECT user_name FROM connections WHERE user_hash = '%s'", req.QueryStringParameters["user"]))
	return ApiResponse(200, fmt.Sprintf(`{"status": 200, "response": %v}`, users))
}

// Delete a linked account from the database
func DeleteLinkedAccount(req events.APIGatewayProxyRequest, db *sql.DB) (*events.APIGatewayProxyResponse, error) {
	var (
		userHash     string = req.QueryStringParameters["user"]
		userToDelete string = req.Headers["delete"]
		authToken    string = req.Headers["auth_token"]
	)

	// Check Auth Token
	if !Auth.CheckAuthToken(authToken, userHash+":"+userToDelete) {
		return ApiResponse(401, `{"status": 401, "response": "invalid token (1)"}`)
	}
	if !Auth.CheckTokenUsage(authToken, userHash) {
		return ApiResponse(401, `{"status": 401, "response": "invalid token (2)"}`)
	}
	// Update database
	if Database.Exists(db, fmt.Sprintf("SELECT * FROM connections WHERE user_hash = '%s' AND user_name = '%s'", userHash, userToDelete)) { // if the user exists
		if Database.Delete(db, fmt.Sprintf("DELETE FROM connections WHERE user_hash = '%s' AND user_name = '%s'", userHash, userToDelete)) {
			return ApiResponse(200, `{"status": 200, "response": "successfully unlinked account"}`)
		}
	}
	return ApiResponse(401, `{"status": 401, "response": "failed to unlink account"}`)
}

// Add the user to the database after discord verification
func AccountLinkTokenHandler(req events.APIGatewayProxyRequest, db *sql.DB) (*events.APIGatewayProxyResponse, error) {
	var (
		_state    string = req.QueryStringParameters["state"]
		code      string = req.QueryStringParameters["code"]
		state, _         = base64.StdEncoding.DecodeString(_state)
		userHash  string = strings.Split(string(state), ":")[0]
		authToken string = strings.Split(string(state), ":")[1]
	)

	// Check Auth Token
	if !Auth.CheckAuthToken(authToken, userHash) {
		return ApiResponseHTML("invalid_token")
	}
	if !Auth.CheckTokenUsage(authToken, userHash) {
		return ApiResponseHTML("invalid_token")
	}

	// Get discord user access token and data
	var (
		token string            = Auth.GetDiscordUserToken(code)["access_token"]
		data  map[string]string = Auth.GetDiscordUserData(string(token))
	)
	if _, ok := data["message"]; ok {
		return ApiResponseHTML("failed")
	}

	// Add the user to the database
	var user string = data["username"] + "#" + data["discriminator"]
	if !Database.Exists(db, fmt.Sprintf("SELECT user_id FROM connections WHERE user_id = %s AND user_hash = '%s'", data["id"], userHash)) {
		if Database.Update(db, fmt.Sprintf("INSERT INTO connections (user_hash, user_id, user_name) VALUES ('%s', %s, '%s')", userHash, data["id"], user)) {
			return ApiResponseHTML("success")
		}
		return ApiResponseHTML("failed")
	}
	return ApiResponseHTML("failed")
}
