package handlers

import (
	Auth "aws-rapid-blocked/authorization"
	Database "aws-rapid-blocked/database"
	"database/sql"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
)

func ApiResponse(status int, body string) (*events.APIGatewayProxyResponse, error) {
	return &events.APIGatewayProxyResponse{
		Headers:    map[string]string{"Content-Type": "application/json"},
		StatusCode: status,
		Body:       body,
	}, nil
}

func GetBlockedUsers(req events.APIGatewayProxyRequest, db *sql.DB) (*events.APIGatewayProxyResponse, error) {
	var users []string = Database.Select(
		db, fmt.Sprintf("SELECT blocked_user FROM blocked_users WHERE user_hash = '%s'", req.QueryStringParameters["user"]))
	return ApiResponse(200, fmt.Sprintf(`{"status": 200, "response": %v}`, users))
}

func BlockUser(req events.APIGatewayProxyRequest, db *sql.DB) (*events.APIGatewayProxyResponse, error) {
	var (
		userToBlock string = req.Headers["block"]
		userHash    string = req.QueryStringParameters["user"]
		authToken   string = req.Headers["auth_token"]
	)

	// Check Auth Token
	if !Auth.CheckAuthToken(authToken, userHash+":"+userToBlock) {
		return ApiResponse(401, `{"status": 401, "response": "invalid token (1)"}`)
	}
	if !Auth.CheckTokenUsage(authToken, userHash) {
		return ApiResponse(401, `{"status": 401, "response": "invalid token (2)"}`)
	}
	if !Database.Exists(db, fmt.Sprintf("SELECT * FROM blocked_users WHERE user_hash = '%s' AND blocked_user = '%s'", userHash, userToBlock)) {
		if Database.Update(db, fmt.Sprintf("INSERT INTO blocked_users (user_hash, blocked_user) VALUES ('%s', '%s')", userHash, userToBlock)) {
			return ApiResponse(200, `{"status": 200, "response": "successfully blocked user"}`)
		}
	}
	return ApiResponse(401, `{"status": 401, "response": "failed to block user"}`)
}

func UnblockUser(req events.APIGatewayProxyRequest, db *sql.DB) (*events.APIGatewayProxyResponse, error) {
	var (
		userHash      string = req.QueryStringParameters["user"]
		userToUnblock string = req.Headers["unblock"]
		authToken     string = req.Headers["auth_token"]
	)

	// Check Auth Token
	if !Auth.CheckAuthToken(authToken, userHash+":"+userToUnblock) {
		return ApiResponse(401, `{"status": 401, "response": "invalid token (1)"}`)
	}
	if !Auth.CheckTokenUsage(authToken, userHash) {
		return ApiResponse(401, `{"status": 401, "response": "invalid token (2)"}`)
	}
	if Database.Exists(db, fmt.Sprintf("SELECT * FROM blocked_users WHERE user_hash = '%s' AND blocked_user = '%s'", userHash, userToUnblock)) {
		if Database.Delete(db, fmt.Sprintf("DELETE FROM blocked_users WHERE user_hash = '%s' AND blocked_user = '%s'", userHash, userToUnblock)) {
			return ApiResponse(200, `{"status": 200, "response": "successfully unblocked user"}`)
		}
	}
	return ApiResponse(401, `{"status": 401, "response": "failed to unblock user"}`)
}
