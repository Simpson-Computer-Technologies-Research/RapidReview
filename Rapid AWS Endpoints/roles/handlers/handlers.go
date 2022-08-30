package handlers

import (
	Auth "aws-rapid-roles/authorization"
	"fmt"
	"io"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
)

func ApiResponse(status int, body string) (*events.APIGatewayProxyResponse, error) {
	return &events.APIGatewayProxyResponse{
		Headers:    map[string]string{"Content-Type": "application/json"},
		StatusCode: status,
		Body:       body,
	}, nil
}

func EditRole(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	var (
		userAuthToken string       = req.Headers["user_auth_token"]
		userHash      string       = req.QueryStringParameters["user"]
		authToken     string       = req.Headers["auth_token"]
		client        *http.Client = &http.Client{}
	)

	// Token Verification
	if authToken == "" || userHash == "" || userAuthToken == "" {
		return ApiResponse(401, `{"status": 401, "response": "invalid token (1)"}`)
	}
	if !Auth.CheckTokenUsage(authToken, userHash) {
		return ApiResponse(401, `{"status": 401, "response": "invalid token (2)"}`)
	}
	if !Auth.CheckAuthToken(userAuthToken, req.QueryStringParameters["guild_id"]+":"+req.QueryStringParameters["role_id"]+":"+req.QueryStringParameters["user_id"]) {
		return ApiResponse(401, `{"status": 401, "response": "invalid token (3)"}`)
	}
	if !Auth.CheckAuthToken(authToken, userHash) {
		return ApiResponse(401, `{"status": 401, "response": "invalid token (4)"}`)
	}

	// Send Discord API Request
	discordRequest, _ := http.NewRequest(req.HTTPMethod,
		"https://discord.com/api/v9/guilds/"+req.QueryStringParameters["guild_id"]+"/members/"+req.QueryStringParameters["user_id"]+"/roles/"+req.QueryStringParameters["role_id"], nil)
	discordRequest.Header = http.Header{
		"Content-Type":  []string{"application/json"},
		"Authorization": []string{"Bot TOKEN"},
	}

	var res, _ = client.Do(discordRequest)
	if res.StatusCode == 204 {
		return ApiResponse(200, `{"status": 200, "response": "success"}`)
	}
	var bodyBytes, _ = io.ReadAll(res.Body)
	return ApiResponse(500, fmt.Sprintf(`{"status": 500, "response": "%v"}`, string(bodyBytes)))
}
